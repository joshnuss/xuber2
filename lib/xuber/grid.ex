defmodule XUber.Grid do
  use Supervisor

  @tile_size Application.get_env(:xuber, :tile_size)

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.Grid)

  def init(:ok) do
    children =
      Enum.map(grid_coordinates(), fn coordinates ->
        id = to_name(coordinates)
        mfa = {XUber.Tile, :start_link, [id, coordinates]}

        %{id: id, start: mfa}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def join(pid, coordinates, traits \\ []),
    do: call(coordinates, {:join, pid, coordinates, traits})

  def leave(pid, coordinates),
    do: call(coordinates, {:leave, pid})

  def update(pid, last_position, new_position),
    do: call(last_position, {:update, pid, new_position})

  def nearby(coordinates, radius, options \\ []) do
    coordinates
    |> surrounding(radius)
    |> Enum.map(&call(&1, {:nearby, coordinates, radius, options}))
    |> Enum.map(fn {:ok, response} -> response end)
    |> List.flatten()
    |> Enum.sort(fn {_, _, a}, {_, _, b} -> a >= b end)
  end

  defp surrounding(coordinates, radius) do
    cond do
      radius < @tile_size ->
        [coordinates]

      true ->
        # TODO: determine tiles inside radius
        []
    end
  end

  defp origin({latitude, longitude}),
    do: {div(latitude, @tile_size), div(longitude, @tile_size)}

  defp to_name(coordinates) do
    {latitude, longitude} = origin(coordinates)

    :"tile-#{latitude}-#{longitude}"
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
