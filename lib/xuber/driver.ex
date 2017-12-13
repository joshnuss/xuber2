defmodule XUber.Driver do
  use GenServer

  def start_link(user) do
    state = %{
      user: user,
      trip: nil,
      status: :online,
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def handle_call(:available, _from, state=%{status: status}) when status != :driving and status != :dispatched,
    do: {:reply, :ok, %{state | status: :available}}

  def handle_call(:unavailable, _from, state=%{status: :available}),
    do: {:reply, :ok, %{state | status: :online}}

  def handle_call(:offline, _from, state=%{status: status}) when status == :available or status == :online,
    do: {:stop, :shutdown, state}

  def handle_call({:assign, trip, passenger}, _from, state=%{status: :available}) do
    {:reply, :ok, %{state | trip: trip, passenger: passenger, status: :dispatched}}
  end

  def handle_call(:pickup, _from, state=%{status: :dispatched, trip: trip}) when not is_nil(trip) do
    {:reply, :ok, %{state | status: :driving}}
  end

  def handle_call(:dropoff, _from, state=%{status: :driving, trip: trip}) when not is_nil(trip) do
    {:reply, :ok, %{state | trip: nil, passenger: nil, status: :available}}
  end

  def handle_call({:move, coordinates}, _from, state) do
    # todo update tile managager
    # leave tile if needed
    {:reply, :ok, state}
  end

  def offline(pid),
    do: GenServer.call(pid, :offline)

  def available(pid),
    do: GenServer.call(pid, :available)

  def unavailable(pid),
    do: GenServer.call(pid, :unavailable)

  def assign(pid, trip, passenger),
    do: GenServer.call(:pid, {:assign, trip, passenger})

  def pickup(pid),
    do: GenServer.call(pid, :pickup)

  def dropoff(pid),
    do: GenServer.call(pid, :dropoff)

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})
end
