defmodule XUber.Pickup do
  use GenServer, restart: :transient

  def start_link([passenger, driver, coordinates]) do
    state = %{
      passenger: passenger,
      driver: driver,
      coordinates: coordinates,
      points: [],
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:move, coordinates}, _from, state=%{points: points}),
    do: {:reply, :ok, %{state | points: [{DateTime.utc_now, coordinates}|points]}}

  def handle_call(:cancel, _from, state),
    do: {:stop, :normal, :ok, state}

  def handle_call(:complete, _from, state),
    do: {:stop, :normal, :ok, state}

  def cancel(pid),
    do: GenServer.call(pid, :cancel)

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})

  def complete(pid),
    do: GenServer.call(pid, :complete)
end
