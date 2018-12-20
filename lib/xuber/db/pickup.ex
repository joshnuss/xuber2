defmodule XUber.DB.Pickup do
  use Ecto.Schema

  alias XUber.DB.{
    Log,
    Request
  }

  schema "pickups" do
    belongs_to(:request, Request)
    has_many(:logs, Log)

    field(:driver, :string)
    field(:passenger, :string)
    field(:status, :string, default: "dispatched")
    field(:departed_at, :utc_datetime_usec)
    field(:arrived_at, :utc_datetime_usec)
    field(:latitude, :float)
    field(:longitude, :float)

    timestamps()
  end
end
