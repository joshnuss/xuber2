defmodule XUber.Pickup do
  use GenServer

  def start_link(_, passenger, driver) do
    state = %{
      passenger: passenger,
      driver: driver,
      points: [],
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def handle_call({:move, coordinates}, _from, state=%{points: points}),
    do: {:reply, :ok, %{state | points: [{Time.utc_now, coordinates}|points]}}

  def handle_call(:cancel, _from, state),
    do: {:stop, :normal, state}

  def handle_call(:complete, _from, state) do
    IO.puts "Finished pickup: #{inspect state}"
    {:stop, :normal, state}
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})

  def complete(pid),
    do: GenServer.call(pid, :complete)
end
