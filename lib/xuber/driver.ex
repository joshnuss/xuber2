defmodule XUber.Driver do
  use GenServer, restart: :transient

  alias XUber.{
    Grid,
    RideSupervisor,
    Passenger,
    Pickup
  }

  def start_link([user, coordinates]) do
    state = %{
      user: user,
      coordinates: coordinates,
      pickup: nil,
      passenger: nil,
      ride: nil,
      status: :online,
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    Grid.join(self(), state.coordinates)

    {:ok, state}
  end

  def handle_call(:available, _from, state=%{status: status}) when status != :driving and status != :dispatched,
    do: {:reply, :ok, %{state | status: :available}}

  def handle_call(:unavailable, _from, state=%{status: :available}),
    do: {:reply, :ok, %{state | status: :online}}

  def handle_call(:offline, _from, state=%{status: status}) when status == :available or status == :online,
    do: {:stop, :normal, :ok, state}

  def handle_call({:dispatched, pickup, passenger}, _from, state) do
    {:reply, :ok, %{state | pickup: pickup, passenger: passenger, status: :dispatched}}
  end

  def handle_call(:arrived, _from, state=%{pickup: pickup, passenger: passenger, status: :dispatched}) when not is_nil(pickup) do
    Pickup.complete(pickup)
    {:ok, ride} = RideSupervisor.start_child(passenger, self(), state.coordinates)
    Passenger.depart(passenger, ride)

    {:reply, :ok, %{state | ride: ride, pickup: nil, status: :riding}}
  end

  def handle_call(:dropoff, _from, state=%{status: :driving, ride: ride}) when not is_nil(ride) do
    {:reply, :ok, %{state | ride: nil, passenger: nil, status: :available}}
  end

  def handle_call({:move, coordinates}, _from, state) do
    Tile.update(self(), state.coordinates, coordinates)

    {:reply, :ok, %{state | coordinates: coordinates}}
  end

  def offline(pid),
    do: GenServer.call(pid, :offline)

  def available(pid),
    do: GenServer.call(pid, :available)

  def unavailable(pid),
    do: GenServer.call(pid, :unavailable)

  def dispatch(pid, pickup, passenger),
    do: GenServer.call(pid, {:dispatched, pickup, passenger})

  def arrive(pid),
    do: GenServer.call(pid, :arrived)

  def dropoff(pid),
    do: GenServer.call(pid, :dropoff)

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})
end
