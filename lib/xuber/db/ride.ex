defmodule XUber.DB.Ride do
  use Ecto.Schema

  alias XUber.DB.{
    Log,
    Pickup
  }

  schema "rides" do
    belongs_to(:pickup, Pickup)
    has_many(:logs, Log)

    field(:driver, :string)
    field(:passenger, :string)
    field(:state, :string, default: "dispatched")
    field(:departed_at, :utc_datetime_usec)
    field(:arrived_at, :utc_datetime_usec)
    field(:latitude, :float)
    field(:longitude, :float)

    timestamps()
  end
end
