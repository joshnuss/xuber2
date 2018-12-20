defmodule XUber.DB do
  alias Ecto.{
    Changeset,
    Multi
  }

  alias XUber.Repo

  alias XUber.DB.{
    Log,
    Pickup,
    Request,
    Ride
  }

  def create_request(
        passenger,
        _from = {from_latitude, from_longitude},
        _to = {to_latitude, to_longitude}
      ) do
    request = %Request{
      passenger: passenger,
      from_latitude: from_latitude,
      from_longitude: from_longitude,
      to_latitude: to_latitude,
      to_longitude: to_longitude
    }

    Repo.insert(request)
  end

  def create_pickup(request, driver) do
    pickup = %Pickup{
      request_id: request.id,
      driver: driver,
      passenger: request.passenger,
      latitude: request.from_latitude,
      longitude: request.from_longitude,
      departed_at: DateTime.utc_now()
    }

    Repo.insert(pickup)
  end

  def create_ride(pickup) do
    ride = %Ride{
      pickup_id: pickup.id,
      driver: pickup.driver,
      passenger: pickup.passenger,
      latitude: pickup.latitude,
      longitude: pickup.longitude,
      departed_at: DateTime.utc_now()
    }

    Multi.new()
    |> Multi.update(:pickup, pickup_arrived(pickup))
    |> Multi.insert(:ride, ride)
    |> Repo.transaction()
  end

  def ride_arrived(ride) do
    ride = Changeset.change(ride, state: "arrived", arrived_at: DateTime.utc_now())

    Repo.update(ride)
  end

  def log_pickup_location(pickup = %Pickup{}, location) do
    log_location(:pickup_id, pickup.id, location)
  end

  def log_ride_location(ride = %Ride{}, location) do
    log_location(:ride_id, ride.id, location)
  end

  defp log_location(type, reference_id, location) do
    {latitude, longitude} = location

    %Log{latitude: latitude, longitude: longitude}
    |> Map.put(type, reference_id)
    |> Repo.insert()
  end

  defp pickup_arrived(pickup) do
    Changeset.change(pickup, state: "arrived", arrived_at: DateTime.utc_now())
  end
end
