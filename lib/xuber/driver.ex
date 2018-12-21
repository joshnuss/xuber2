defmodule XUber.Driver do
  use GenStateMachine, restart: :transient

  alias XUber.{
    DB,
    Grid,
    RideSupervisor,
    Passenger,
    Ride
  }

  def start_link([user, coordinates]) do
    data = %{
      user: user,
      coordinates: coordinates,
      pickup: nil,
      passenger: nil,
      ride: nil
    }

    name = String.to_atom(user.name)

    GenStateMachine.start_link(__MODULE__, data, name: name)
  end

  def init(data) do
    Grid.join(self(), data.coordinates, [:driver])

    PubSub.publish(:driver, {data.user, :init, data.coordinates})

    {:ok, :online, data}
  end

  def handle_event({:call, from}, :available, :online, data) do
    PubSub.publish(:driver, {data.user, :available})
    reply = {:reply, from, :ok}

    {:next_state, :available, data, reply}
  end

  def handle_event({:call, from}, :unavailable, :available, data) do
    PubSub.publish(:driver, {data.user, :unavailable})
    reply = {:reply, from, :ok}

    {:next_state, :online, data, reply}
  end

  def handle_event({:call, from}, :offline, status, data)
      when status == :available or status == :online do
    PubSub.publish(:driver, {data.user, :offline})
    reply = {:reply, from, :ok}

    {:stop_and_reply, :normal, reply, data}
  end

  def handle_event({:call, from}, {:dispatch, pickup, passenger}, :available, data) do
    PubSub.publish(:driver, {data.user, :dispatch, pickup, passenger})

    reply = {:reply, from, :ok}
    new_data = %{data | pickup: pickup, passenger: passenger}

    {:next_state, :dispatched, new_data, reply}
  end

  def handle_event({:call, from}, :arrived, :dispatched, data) do
    PubSub.publish(:driver, {data.user, :arrived, data.coordinates})

    {:ok, ride} = RideSupervisor.start_child(data.pickup, data.passenger, self())
    Passenger.depart(data.passenger, ride)

    PubSub.publish(:driver, {data.user, :departed, ride})

    reply = {:reply, from, {:ok, ride}}
    new_data = %{data | ride: ride, pickup: nil}

    {:next_state, :riding, new_data, reply}
  end

  def handle_event({:call, from}, :dropoff, :riding, data = %{ride: ride})
      when not is_nil(ride) do
    PubSub.publish(:driver, {data.user, :dropoff, data.passenger, data.coordinates})

    :ok = Ride.complete(ride)

    reply = {:reply, from, {:ok, ride}}
    new_data = %{data | ride: nil, passenger: nil}

    {:next_state, :available, new_data, reply}
  end

  def handle_event({:call, from}, {:move, coordinates}, _any, data) do
    PubSub.publish(:driver, {data.user, :move, coordinates})

    Grid.update(self(), data.coordinates, coordinates)

    if data.pickup, do: DB.log_pickup_location(data.pickup, coordinates)
    if data.ride, do: Ride.move(data.ride, coordinates)

    reply = {:reply, from, :ok}
    new_data = %{data | coordinates: coordinates}

    {:keep_state, new_data, reply}
  end

  def handle_event({:call, from}, :get_user, _any, data) do
    reply = {:reply, from, {:ok, data.user}}

    {:keep_state, data, reply}
  end

  def offline(pid),
    do: GenStateMachine.call(pid, :offline)

  def available(pid),
    do: GenStateMachine.call(pid, :available)

  def unavailable(pid),
    do: GenStateMachine.call(pid, :unavailable)

  def dispatch(pid, pickup, passenger),
    do: GenStateMachine.call(pid, {:dispatch, pickup, passenger})

  def arrive(pid),
    do: GenStateMachine.call(pid, :arrived)

  def dropoff(pid),
    do: GenStateMachine.call(pid, :dropoff)

  def move(pid, coordinates),
    do: GenStateMachine.call(pid, {:move, coordinates})

  def get_user(pid),
    do: GenStateMachine.call(pid, :get_user)
end
