defmodule XUber.DB.PickupRequest do
  use Ecto.Schema

  alias XUber.DB.Point

  schema "pickup_requests" do
    field :passenger, :string
    field :state, :string, default: "searching"
    field :from_latitude, :float
    field :from_longitude, :float
    field :to_latitude, :float
    field :to_longitude, :float

    timestamps()
  end
end
