defmodule XUber.Grid do
  use Supervisor

  @tile_size Application.get_env(:xuber, :tile_size)

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.Grid)

  def init(:ok) do
    children = Enum.map grid_coordinates(), fn coordinates ->
      id = to_name(coordinates)
      mfa = {XUber.Tile, :start_link, [id, coordinates]}

      %{id: id, start: mfa}
    end

    Supervisor.init(children, strategy: :one_for_one)
  end

  def join(pid, coordinates),
    do: call(coordinates, {:join, pid, coordinates})

  def leave(pid, coordinates),
    do: call(coordinates, {:leave, pid})

  def update(pid, last_position, new_position),
    do: call(last_position, {:update, pid, new_position})

  def nearby(coordinates, radius, options \\ []),
    do: call(coordinates, {:nearby, coordinates, radius, options})

  defp to_name({latitude, longitude}) do
    tile_latitude = div(latitude, @tile_size)
    tile_longitude = div(longitude, @tile_size)

    :"tile-#{tile_latitude}-#{tile_longitude}"
  end

  defp call(coordinates, arguments) do
    coordinates
    |> to_name
    |> GenServer.call(arguments)
  end

  defp grid_coordinates do
    for latitude <- -90..90,
        longitude <- -180..180,
        rem(latitude, @tile_size) == 0,
        rem(longitude, @tile_size) == 0 do
      {latitude, longitude}
    end
  end
end
