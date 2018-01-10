defmodule XUber.Passenger do
  use GenServer, restart: :transient

  alias XUber.{
    Grid,
    DispatcherSupervisor
  }

  def start_link([user, coordinates]) do
    state = %{
      user: user,
      coordinates: coordinates,
      request: nil,
      pickup: nil,
      ride: nil,
      driver: nil,
      status: :online,
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    Grid.join(self(), state.coordinates)

    {:ok, state}
  end

  def handle_call(:offline, _from, state),
    do: {:stop, :normal, :ok, state}

  def handle_call({:request, coordinates}, _from, state) do
    {:ok, request} = DispatcherSupervisor.start_child(self(), coordinates)

    {:reply, {:ok, request}, %{state | request: request, status: :requesting}}
  end

  def handle_call({:dispatched, pickup, driver}, _from, state) do
    {:reply, {:ok, pickup}, %{state | pickup: pickup, driver: driver, request: nil, status: :waiting}}
  end

  def handle_call(:cancel, _from, state=%{status: :waiting, ride: ride}) when not is_nil(ride) do
    {:reply, Ride.cancel(ride), %{state | ride: nil, status: :online}}
  end

  def handle_call({:depart, ride}, _from, state=%{status: :waiting, pickup: pickup, driver: driver}) when not is_nil(driver) and not is_nil(pickup) do
    {:reply, :ok, %{state | ride: ride, pickup: nil, status: :riding}}
  end

  def handle_call(:arrive, _from, state=%{status: :riding, ride: ride}) when not is_nil(ride) do
    {:reply, :ok, %{state | ride: nil, driver: nil, status: :online}}
  end

  def handle_call({:move, coordinates}, _from, state) do
    Tile.update(self(), state.coordinates, coordinates)

    {:reply, :ok, %{state | coordinates: coordinates}}
  end

  def offline(pid),
    do: GenServer.call(pid, :offline)

  def request(pid, coordinates),
    do: GenServer.call(pid, {:request, coordinates})

  def cancel(pid),
    do: GenServer.call(pid, :cancel)

  def dispatched(pid, pickup, driver),
    do: GenServer.call(pid, {:dispatched, pickup, driver})

  def depart(pid, ride),
    do: GenServer.call(pid, {:depart, ride})

  def arrive(pid),
    do: GenServer.call(pid, :arrive)

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})
end
