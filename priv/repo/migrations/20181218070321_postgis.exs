defmodule XUber.Repo.Migrations.Postgis do
  use Ecto.Migration

  def up do
    execute("create extension postgis")
  end

  def down do
    execute("drop extension postgis")
  end
end
