defmodule XUber.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:pickup_requests) do
      add(:passenger, :string)
      add(:state, :string)
      add(:from, :point)
      add(:to, :point)

      timestamps()
    end

    create table(:pickups) do
      add(:pickup_request_id, references(:pickup_requests))
      add(:driver, :string)
      add(:passenger, :string)
      add(:state, :string)
      add(:departed_at, :utc_datetime)
      add(:arrived_at, :utc_datetime)
      add(:location, :point)

      timestamps()
    end

    create table(:rides) do
      add(:pickup_id, references(:pickups))
      add(:driver, :string)
      add(:passenger, :string)
      add(:state, :string)
      add(:departed_at, :utc_datetime)
      add(:arrived_at, :utc_datetime)
      add(:location, :point)

      timestamps()
    end

    create table(:logs) do
      add(:reference_id, :int)
      add(:type, :string)
      add(:location, :point)

      timestamps()
    end

    create index(:logs, [:reference_id, :type])
  end
end
