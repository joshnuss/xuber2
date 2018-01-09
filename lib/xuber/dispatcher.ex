defmodule XUber.Dispatcher do
  use GenServer

  alias XUber.{
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

  def handle_info(:request, state = %{passenger: passenger}) do
    {:ok, nearby} = Grid.nearby(state.coordinates, @search_radius)

    driver = nearby
      |> Enum.drop_while(&(&1 !== passenger))
      |> List.first

    pickup = create_pickup(driver, passenger)

    # TODO: update #assign to handle `pickup` (instead of `ride`)
    Passenger.dispatched(passenger, pickup, driver)
    Driver.dispatched(driver, pickup, passenger)

    {:noreply, state}
  end

  defp create_pickup(driver, passenger) do
    # TODO contact PickupSuperisor
  end

  def cancel(pid),
    do: GenServer.call(pid, :cancel)
end
