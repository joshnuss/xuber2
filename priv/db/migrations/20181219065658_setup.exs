defmodule XUber.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:pickup_requests) do
      add(:passenger, :string, null: false)
      add(:state, :string, null: false)
      add(:from_latitude, :float, null: false)
      add(:from_longitude, :float, null: false)
      add(:to_latitude, :float, null: false)
      add(:to_longitude, :float, null: false)

      timestamps()
    end

    create table(:pickups) do
      add(:pickup_request_id, references(:pickup_requests))
      add(:driver, :string, null: false)
      add(:passenger, :string, null: false)
      add(:state, :string, null: false)
      add(:departed_at, :utc_datetime)
      add(:arrived_at, :utc_datetime)
      add(:latitude, :float, null: false)
      add(:longitude, :float, null: false)

      timestamps()
    end

    create table(:rides) do
      add(:pickup_id, references(:pickups))
      add(:driver, :string, null: false)
      add(:passenger, :string, null: false)
      add(:state, :string, null: false)
      add(:departed_at, :utc_datetime)
      add(:arrived_at, :utc_datetime)
      add(:latitude, :float, null: false)
      add(:longitude, :float, null: false)

      timestamps()
    end

    create table(:logs) do
      add(:reference_id, :int, null: false)
      add(:type, :string, null: false)
      add(:latitude, :float, null: false)
      add(:longitude, :float, null: false)

      timestamps()
    end

    create index(:logs, [:reference_id, :type])
  end
end
