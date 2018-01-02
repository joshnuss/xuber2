# TODO determine how to handle state here
# the dispatcher should find the driver
# and then wait for the driver to arrive
# or maybe start the ride at the time the driver is found
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
    do: {:stop, :normal, :ok, state}

  def handle_info(:request, state) do
    driver = state.coordinates
      |> nearby_drivers
      |> List.first

    ride = create_ride(driver, state.passenger)

    Passenger.assign(state.passenger, ride, driver)
    Driver.assign(driver, ride, state.passenger)

    {:noreply, state}
  end

  defp nearby_drivers(coordinates) do
    [] # TODO contact TileSupervisor
  end

  defp create_ride(driver, passenger) do
    # TODO contact RideSuperisor
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)
end
