defmodule XUber.Dispatcher do
  use GenServer

  alias XUber.{
    PickupSupervisor,
    Driver,
    Passenger,
    Grid
  }

  @search_radius 5

  def start_link([passenger, coordinates]) do
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

  def handle_info(:request, state = %{coordinates: coordinates, passenger: passenger}) do
    {:ok, nearest} = Grid.nearby(coordinates, @search_radius)

    driver = nearest
      |> Enum.filter(&(&1 !== passenger))
      |> List.first # TODO: ensure it's a driver

    {:ok, pickup} = PickupSupervisor.start_child(driver, passenger, coordinates)

    Driver.dispatch(driver, pickup, passenger)
    Passenger.dispatched(passenger, pickup, driver)

    {:noreply, state}
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)
end
