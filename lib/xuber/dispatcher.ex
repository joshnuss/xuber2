# TODO determine how to handle state here
# the dispatcher should find the driver
# and then wait for the driver to arrive
# or maybe start the trip at the time the driver is found
# or is there an intermediate collaborator
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
    do: {:stop, :shutdown, state}

  def handle_info(:request, state) do
    driver = state.coordinates
      |> nearby_drivers
      |> List.first

    trip = create_trip(driver, state.passenger)

    Passenger.assign(state.passenger, trip, driver)
    Driver.assign(driver, trip, state.passenger)

    {:noreply, state}
  end

  defp nearby_drivers(coordinates) do
    [] # TODO contact TileSupervisor
  end

  defp create_trip(driver, passenger) do
    # TODO contact TripSuperisor
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)
end
