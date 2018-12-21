defmodule XUber.Ride do
  use GenServer, restart: :transient

  alias XUber.Passenger

  def start_link([ride, passenger, driver]) do
    state = %{
      ride: ride,
      passenger: passenger,
      driver: driver,
      points: []
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    PubSub.publish(:ride, {self(), :init, state.passenger, state.driver})
    {:ok, state}
  end

  def handle_call({:move, coordinates}, _from, state = %{points: points}) do
    PubSub.publish(:ride, {self(), :move, coordinates})

    {:reply, :ok, %{state | points: [{DateTime.utc_now(), coordinates} | points]}}
  end

  def handle_call(:complete, _from, state) do
    {_data, coordinates} = hd(state.points)

    PubSub.publish(:ride, {self(), :complete, coordinates})
    Passenger.arrive(state.passenger)
    {:stop, :normal, :ok, state}
  end

  def move(pid, coordinates),
    do: GenServer.call(pid, {:move, coordinates})

  def complete(pid),
    do: GenServer.call(pid, :complete)
end
