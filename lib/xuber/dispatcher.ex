defmodule XUber.Dispatcher do
  use GenServer

  def start_link(passenger, coordinates) do
    state = %{
      passenger: passenger,
      coordinates: coordinates,
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    send(self(), :request)

    {:ok, state}
  end

  def handle_call(:cancel, _from, state),
    do: {:stop, :normal, :ok, state}

  def handle_info(:request, state) do
    driver = state.coordinates
      |> nearby_drivers
      |> List.first

    pickup = create_pickup(driver, state.passenger)

    # TODO: update #assign to handle `pickup` (instead of `ride`)
    Passenger.assign(state.passenger, pickup, driver)
    Driver.assign(driver, pickup, state.passenger)

    {:noreply, state}
  end

  defp nearby_drivers(coordinates) do
    [] # TODO contact TileSupervisor
  end

  defp create_pickup(driver, passenger) do
    # TODO contact PickupSuperisor
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)
end
