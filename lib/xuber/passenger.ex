defmodule XUber.Passenger do
  use GenServer

  def start_link(user) do
    state = %{
      user: user,
      trip: nil,
      driver: nil,
      status: :online,
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def handle_call(:offline, _from, state),
    do: {:stop, :shutdown, state}

  def handle_call({:request, coordinates}, _from, state) do
    trip = nil # todo, request trip from Dispatcher

    {:reply, {:ok, trip}, %{state | trip: trip, status: :requesting}}
  end

  def handle_call(:cancel, _from, state=%{status: :requesting}) do
    # todo send trip :cancel message
    {:reply, {:ok, state.trip}, %{state | trip: nil, status: :online}}
  end

  def handle_call({:assign, trip, driver}, _from, state=%{status: :requesting}) do
    {:reply, :ok, %{state | trip: trip, driver: driver, status: :waiting}}
  end

  def handle_call(:depart, _from, state=%{status: :waiting, trip: trip}) when not is_nil(trip) do
    {:reply, :ok, %{state | status: :riding}}
  end

  def handle_call(:arrive, _from, state=%{status: :riding, trip: trip}) when not is_nil(trip) do
    {:reply, :ok, %{state | trip: nil, driver: nil, status: :online}}
  end

  def handle_call({:move, coordinates}, _from, state) do
    # todo update tile managager
    # leave tile if needed
    {:reply, :ok, state}
  end

  def offline(pid),
    do: GenServer.call(pid, :offline)

  def request(pid, coordinates),
    do: GenServer.call(pid, {:request, coordinates})

  def cancel(pid),
    do: GenServer.call(pid, :cancel)

  def assign(pid, trip, driver),
    do: GenServer.call(:pid, {:assign, trip, driver})

  def depart(pid),
    do: GenServer.call(pid, :depart)

  def arrive(pid),
    do: GenServer.call(pid, :arrive)

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})
end
