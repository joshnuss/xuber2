defmodule XUber.Grid do
  use Supervisor

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.Grid)

  def init(:ok) do
    tile_size = Application.get_env(:xuber, :tile_size)

    children =
      for latitude <- -90..90,
          longitude <- -180..180,
          rem(latitude, tile_size) == 0,
          rem(longitude, tile_size) == 0 do

      coordinates = {latitude, longitude}

      id = XUber.Tile.to_name(coordinates)
      mfa = {XUber.Tile, :start_link, [coordinates]}

      %{id: id, start: mfa}
    end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
