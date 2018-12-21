defmodule XUber.Pickup do
  use GenServer, restart: :transient

  alias XUber.DB

  def start_link([pickup]) do
    GenServer.start_link(__MODULE__, pickup, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:move, coordinates}, _from, pickup) do
    {:ok, _log} = DB.log_pickup_location(pickup, coordinates)

    {:reply, :ok, pickup}
  end

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
