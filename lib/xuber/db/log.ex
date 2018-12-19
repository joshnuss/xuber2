defmodule XUber.DB.Log do
  use Ecto.Schema

  alias XUber.DB.{
    Pickup,
    Ride
  }

  schema "logs" do
    belongs_to(:pickup, Pickup)
    belongs_to(:ride, Ride)

    field(:latitude, :float)
    field(:longitude, :float)

    timestamps()
  end
end
