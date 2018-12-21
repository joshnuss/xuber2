defmodule XUber.Dispatcher do
  use GenServer

  alias XUber.{
    DB,
    Driver,
    Passenger,
    Grid
  }

  @search_radius 5

  def start_link([passenger, request]) do
    state = %{
      passenger: passenger,
      request: request
    }

    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    send(self(), :request)

    {:ok, state}
  end

  def handle_call(:cancel, _from, state),
    do: {:stop, :normal, :ok, state}

  def handle_info(:request, state = %{request: request, passenger: passenger}) do
    coordinates = { request.from_latitude, request.from_longitude}
    PubSub.publish(:dispatcher, {:request, coordinates, passenger})

    {:ok, driver} = find_driver(passenger, coordinates)

    PubSub.publish(:dispatcher, {:assigned, driver, passenger})

    {:ok, pickup} = create_pickup(request, driver)

    Driver.dispatch(driver, pickup, passenger)
    Passenger.dispatched(passenger, pickup, driver)

    {:noreply, state}
  end

  defp create_pickup(request, driver) do
    {:ok, user} = Driver.get_user(driver)
    {:ok, %{pickup: pickup}} = DB.create_pickup(request, user.name)

    {:ok, pickup}
  end

  defp find_driver(passenger, coordinates) do
    nearest = Grid.nearby(coordinates, @search_radius)

    {driver, _position, _distance} =
      nearest
      |> Enum.filter(fn {pid, _position, _distance} -> pid !== passenger end)
      # TODO: ensure it's an available driver
      |> List.first()

    {:ok, driver}
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)
end
