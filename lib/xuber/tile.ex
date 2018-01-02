defmodule XUber.Tile do
  use GenServer

  @tile_size Application.get_env(:xuber, :tile_size)

  def start_link(coordinates) do
    IO.inspect coordinates

    name = to_name(coordinates)
    state = %{
      jurisdiction: coordinates,
      data: %{},
    }

    GenServer.start_link(__MODULE__, state, name: name)
  end

  def handle_call({:join, name, coordinates}, _from, state) do
    {:reply, :ok, put_in(state[:data][name], coordinates)}
  end

  def handle_call({:leave, name}, _from, state) do
    {:reply, :ok, %{state | data: Map.delete(state.data, name)}}
  end

  def handle_call({:move, name, coordinates}, _from, state) do
    if outside?(state.jurisdiction, coordinates) do
      leave(coordinates, name)
      join(name, coordinates)

      {:reply, :ok, state}
     else
      {:reply, :ok, put_in(state[:data][name], coordinates)}
    end
  end

  def join(name, coordinates),
    do: call(coordinates, {:join, name, coordinates})

  def leave(coordinates, name),
    do: call(coordinates, {:leave, name})

  def move(name, previous, new),
    do: call(previous, {:move, name, new})

  def to_name({latitude, longitude}) do
    tile_latitude = to_integer(latitude/@tile_size)*@tile_size
    tile_longitude = to_integer(longitude/@tile_size)*@tile_size

    :"tile-#{tile_latitude}-#{tile_longitude}"
  end

  defp call(coordinates, arguments) do
    coordinates
    |> to_name
    |> GenServer.call(arguments)
  end

  defp outside?({lat1, lng1}, {lat2, lng2}) do
    to_integer(lat2) > to_integer(lat1+@tile_size) ||
    to_integer(lng2) > to_integer(lng1+@tile_size)
  end

  defp to_integer(n) when is_integer(n),
    do: n
  defp to_integer(float) when is_float(float),
    do: float |> Float.floor |> round
end
