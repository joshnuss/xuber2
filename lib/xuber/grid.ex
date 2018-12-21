defmodule XUber.Grid do
  use Supervisor

  @cell_size Application.get_env(:xuber, :cell_size)

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.Grid)

  def init(:ok) do
    children =
      Enum.map(grid_coordinates(), fn coordinates ->
        id = cell_name(coordinates)
        mfa = {XUber.Cell, :start_link, [id, coordinates]}

        %{id: id, start: mfa}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def join(pid, coordinates, traits \\ []),
    do: call_cell(coordinates, {:join, pid, coordinates, traits})

  def leave(pid, coordinates),
    do: call_cell(coordinates, {:leave, pid})

  def update(pid, last_position, new_position),
    do: call_cell(last_position, {:update, pid, new_position})

  def nearby(coordinates, radius, filters \\ []) do
    coordinates
    |> surrounding_cells(radius)
    |> Enum.map(&call_cell(&1, {:nearby, coordinates, radius, filters}))
    |> Enum.map(fn {:ok, response} -> response end)
    |> List.flatten()
    |> Enum.sort(&closest/2)
  end

  defp surrounding_cells(coordinates, radius) do
    cond do
      radius < @cell_size ->
        [coordinates]

      true ->
        # TODO: determine cells inside radius
        []
    end
  end

  defp closest({_, _, a}, {_, _, b}),
    do: a >= b

  defp origin({latitude, longitude}),
    do: {truncate(latitude), truncate(longitude)}

  defp cell_name(coordinates) do
    {latitude, longitude} = origin(coordinates)

    :"cell-#{latitude}-#{longitude}"
  end

  defp truncate(n) do
    n
    |> trunc()
    |> div(@cell_size)
  end

  defp call_cell(coordinates, arguments) do
    coordinates
    |> cell_name()
    |> GenServer.call(arguments)
  end

  defp grid_coordinates do
    for latitude <- -90..90,
        longitude <- -180..180,
        rem(latitude, @cell_size) == 0,
        rem(longitude, @cell_size) == 0 do
      {latitude, longitude}
    end
  end
end
