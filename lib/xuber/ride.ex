defmodule XUber.Ride do
  use GenServer, restart: :transient

  def start_link([passenger, driver]) do
    state = %{
      passenger: passenger,
      driver: driver,
      points: [],
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def handle_call({:move, coordinates}, _from, state=%{points: points}),
    do: {:reply, :ok, %{state | points: [{Time.utc_now, coordinates}|points]}}

  def handle_call(:complete, _from, state) do
    IO.puts "Finished ride: #{inspect state}"
    {:stop, :normal, :ok, state}
  end

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})

  def complete(pid),
    do: GenServer.call(pid, :complete)
end
