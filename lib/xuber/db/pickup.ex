defmodule XUber.DB.Pickup do
  use Ecto.Schema

  alias XUber.DB.{
    Log,
    PickupRequest
  }

  schema "pickups" do
    belongs_to(:pickup_request, PickupRequest)
    has_many(:logs, Log)

    field(:driver, :string)
    field(:passenger, :string)
    field(:state, :string, default: "dispatched")
    field(:departed_at, :utc_datetime)
    field(:arrived_at, :utc_datetime)
    field(:latitude, :float)
    field(:longitude, :float)

    timestamps()
  end
end
