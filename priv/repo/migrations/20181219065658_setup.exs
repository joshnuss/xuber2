defmodule XUber.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add(:passenger, :string, null: false)
      add(:status, :string, null: false)
      add(:from_latitude, :float, null: false)
      add(:from_longitude, :float, null: false)
      add(:to_latitude, :float, null: false)
      add(:to_longitude, :float, null: false)

      timestamps()
    end

    create table(:pickups) do
      add(:request_id, references(:requests), null: false)
      add(:driver, :string, null: false)
      add(:passenger, :string, null: false)
      add(:status, :string, null: false)
      add(:departed_at, :utc_datetime_usec)
      add(:arrived_at, :utc_datetime_usec)
      add(:latitude, :float, null: false)
      add(:longitude, :float, null: false)

      timestamps()
    end

    create table(:rides) do
      add(:pickup_id, references(:pickups), null: false)
      add(:driver, :string, null: false)
      add(:passenger, :string, null: false)
      add(:status, :string, null: false)
      add(:departed_at, :utc_datetime_usec)
      add(:completed_at, :utc_datetime_usec)
      add(:latitude, :float, null: false)
      add(:longitude, :float, null: false)

      timestamps()
    end

    create table(:logs) do
      add(:pickup_id, references(:pickups))
      add(:ride_id, references(:rides))
      add(:latitude, :float, null: false)
      add(:longitude, :float, null: false)

      timestamps()
    end
  end
end
