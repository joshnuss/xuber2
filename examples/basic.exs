#:observer.start

alias XUber.{User, Driver, Passenger, Ride, UserSupervisor}

defmodule Dispatcher.EventLogger do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_info(event, state) do
    IO.puts message(event)

    {:noreply, state}
  end

  defp message({:request, coordinates, passenger}) do
    "Dispatcher received request for pickup at #{inspect coordinates} for #{inspect passenger}"
  end

  defp message({:assigned, driver, passenger}) do
    "Dispatcher assigned driver #{inspect driver} to pickup #{inspect passenger}"
  end

  defp message(event) do
    "Dispatcher unknown message #{inspect event}"
  end
end

defmodule Ride.EventLogger do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_info(event, state) do
    IO.puts message(event)

    {:noreply, state}
  end

  defp message({ride, :move, coordinates}) do
    "Ride #{inspect ride} is at #{inspect coordinates}"
  end

  defp message({ride, :complete, coordinates}) do
    "Ride #{inspect ride} has been completed. Dropoff location was #{inspect coordinates}"
  end

  defp message(event) do
    "Ride unknown message #{inspect event}"
  end
end

defmodule Driver.EventLogger do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_info(event, state) do
    IO.puts message(event)

    {:noreply, state}
  end

  defp message({driver, :init, coordinates}) do
    "Driver `#{driver.name}` has joined at coordinates #{inspect coordinates}"
  end

  defp message({driver, :available}) do
    "Driver `#{driver.name}` has indicated they are available"
  end

  defp message({driver, :unavailable}) do
    "Driver `#{driver.name}` has indicated they are unavailable"
  end

  defp message({driver, :dispatch, pickup, passenger}) do
    "Driver `#{driver.name}` has been notified to pickup passenger #{inspect passenger}, pickup #{inspect pickup}"
  end

  defp message({driver, :departed, ride}) do
    "Driver `#{driver.name}` has departed, ride #{inspect ride}"
  end

  defp message({driver, :arrived, coordinates}) do
    "Driver `#{driver.name}` has arrived at destination #{inspect coordinates}"
  end

  defp message({driver, :dropoff, passenger, coordinates}) do
    "Driver `#{driver.name}` has dropped off passenger #{inspect passenger} at coordinates #{inspect coordinates}"
  end

  defp message({driver, :offline}) do
    "Driver `#{driver.name}` has gone offline"
  end

  defp message({driver, :move, coordinates}) do
    "Driver `#{driver.name}` has moved to coordinates #{inspect coordinates}"
  end

  defp message(event) do
    "Driver unknown message #{inspect event}"
  end
end

defmodule Passenger.EventLogger do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_info(event, state) do
    IO.puts message(event)

    {:noreply, state}
  end

  defp message({passenger, :init, coordinates}) do
    "Passenger `#{passenger.name}` has joined at coordinates #{inspect coordinates}"
  end

  defp message({passenger, :nearby_search, coordinates, radius}) do
    "Passenger `#{passenger.name}` is searching for drivers within #{radius}km of coordinates #{inspect coordinates}"
  end

  defp message({passenger, :nearby_results, results}) do
    "Passenger `#{passenger.name}` found drivers: #{inspect results}"
  end

  defp message({passenger, :request, coordinates}) do
    "Passenger `#{passenger.name}` has requested a pickup at coordinates #{inspect coordinates}"
  end

  defp message({passenger, :online}) do
    "Passenger `#{passenger.name}` is now online"
  end

  defp message({passenger, :dispatched, pickup, driver}) do
    "Passenger `#{passenger.name}` has been notified that driver #{inspect driver} will pick them up, pickup #{inspect pickup}"
  end

  defp message({passenger, :depart, ride}) do
    "Passenger `#{passenger.name}` has been picked up and is departing with ride #{inspect ride}"
  end

  defp message({passenger, :arrive, coordinates}) do
    "Passenger `#{passenger.name}` has arrived at destination #{inspect coordinates}"
  end

  defp message({passenger, :offline}) do
    "Passenger `#{passenger.name}` has gone offline"
  end

  defp message({passenger, :move, coordinates}) do
    "Passenger `#{passenger.name}` has moved to coordinates #{inspect coordinates}"
  end

  defp message(event) do
    "Passenger unknown message #{inspect event}"
  end
end

{:ok, passenger_logger} = GenServer.start_link(Passenger.EventLogger, [])
{:ok, driver_logger} = GenServer.start_link(Driver.EventLogger, [])
{:ok, dispatcher_logger} = GenServer.start_link(Dispatcher.EventLogger, [])
{:ok, ride_logger} = GenServer.start_link(Ride.EventLogger, [])

PubSub.subscribe(passenger_logger, :passenger)
PubSub.subscribe(driver_logger, :driver)
PubSub.subscribe(dispatcher_logger, :dispatcher)
PubSub.subscribe(ride_logger, :ride)

{:ok, passenger} = UserSupervisor.start_child %User{type: :passenger, name: "mary"}, {10, 10}

:timer.sleep 10

{:ok, driver} = UserSupervisor.start_child(%User{type: :driver, name: "tom"}, {10, 10})

Driver.available(driver)

:timer.sleep(3000)

{:ok, _request} = Passenger.request(passenger, {10, 10})

:timer.sleep(100)

Driver.move(driver, {10, 15})

:timer.sleep(200)

Driver.move(driver, {10, 16})

:timer.sleep(100)
:timer.sleep(2000)

Driver.arrive(driver)

:timer.sleep(100)

{_, %{ride: ride}} = :sys.get_state(driver)

for position <- [{10, 16}, {10, 17}, {10, 18}] do
  Ride.move(ride, position)
  Driver.move(driver, position)
  Passenger.move(passenger, position)
end

Driver.dropoff(driver)

:timer.sleep(100)

Driver.unavailable(driver)
Driver.offline(driver)
Passenger.offline(passenger)
