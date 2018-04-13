defmodule XUber.Driver do
  use GenStateMachine, restart: :transient

  alias XUber.{
    Grid,
    RideSupervisor,
    Passenger,
    Pickup,
    Ride,
  }

  def start_link([user, coordinates]) do
    data = %{
      user: user,
      coordinates: coordinates,
      pickup: nil,
      passenger: nil,
      ride: nil,
    }

    GenStateMachine.start_link(__MODULE__, data, [])
  end

  def init(data) do
    Grid.join(self(), data.coordinates, [:driver])

    {:ok, :online, data}
  end

  def handle_event({:call, from}, :available, :online, data) do
    reply = {:reply, from, :ok}

    {:next_state, :available, data, reply}
  end

  def handle_event({:call, from}, :unavailable, :available, data) do
    reply = {:reply, from, :ok}

    {:next_state, :online, data, reply}
  end

  def handle_event({:call, from}, :offline, status, data) when status == :available or status == :online do
    reply = {:reply, from, :ok}

    {:stop, :normal, data, reply}
  end

  def handle_event({:call, from}, {:dispatch, pickup, passenger}, :online, data) do
    reply = {:reply, from, :ok}
    new_data = %{data | pickup: pickup, passenger: passenger}

    {:next_state, :dispatched, new_data, reply}
  end

  def handle_event({:call, from}, :arrived, :dispatched, data) do
    :ok = Pickup.complete(data.pickup)
    {:ok, ride} = RideSupervisor.start_child(data.passenger, self(), data.coordinates)
    Passenger.depart(data.passenger, ride)

    reply = {:reply, from, {:ok, ride}}
    new_data = %{data | ride: ride, pickup: nil}

    {:next_state, :riding, new_data, reply}
  end

  def handle_event({:call, from}, :dropoff, :riding, data=%{ride: ride}) when not is_nil(ride) do
    :ok = Ride.complete(ride)

    reply = {:reply, from, {:ok, ride}}
    new_data = %{data | ride: nil, passenger: nil}

    {:next_state, :available, new_data, reply}
  end

  def handle_event({:call, from}, {:move, coordinates}, _any, data) do
    Grid.update(self(), data.coordinates, coordinates)

    if data.pickup, do: Pickup.move(data.pickup, coordinates)
    if data.ride, do: Ride.move(data.ride, coordinates)

    reply = {:reply, from, :ok}
    new_data = %{data | coordinates: coordinates}

    {:keep_state, new_data, reply}
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
end
