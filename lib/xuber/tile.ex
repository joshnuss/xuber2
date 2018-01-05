defmodule XUber.Tile do
  use GenServer

  @tile_size Application.get_env(:xuber, :tile_size)

  def start_link(coordinates) do
    name = to_name(coordinates)
    state = %{
      jurisdiction: coordinates,
      data: %{},
    }

    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:join, pid, coordinates}, _from, state) do
    {:reply, :ok, put_in(state[:data][pid], coordinates)}
  end

  def handle_call({:leave, pid}, _from, state) do
    {:reply, :ok, %{state | data: Map.delete(state.data, pid)}}
  end

  def handle_call({:update, pid, coordinates}, _from, state) do
    if Coordinates.outside?(state.jurisdiction, coordinates) do
      leave(pid, coordinates)
      join(pid, coordinates)

      {:reply, :ok, state}
     else
      {:reply, :ok, put_in(state[:data][pid], coordinates)}
    end
  end

  def join(pid, coordinates),
    do: call(coordinates, {:join, pid, coordinates})

  def leave(pid, coordinates),
    do: call(coordinates, {:leave, pid})

  def update(pid, last_position, new_position),
    do: call(last_position, {:update, pid, new_position})

  def to_name({latitude, longitude}) do
    tile_latitude = div(latitude, @tile_size)
    tile_longitude = div(longitude, @tile_size)

    :"tile-#{tile_latitude}-#{tile_longitude}"
  end

  defp call(coordinates, arguments) do
    coordinates
    |> to_name
    |> GenServer.call(arguments)
  end
end
