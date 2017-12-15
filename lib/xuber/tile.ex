defmodule XUber.Tile do
  use GenServer

  def start_link(coordinates) do
    IO.inspect coordinates
    state = %{
      jurisdiction: coordinates,
      data: %{},
    }

    GenServer.start_link(__MODULE__, state, name: name(coordinates))
  end

  def handle_call({:join, name, coordinates}, _from, state) do
    {:reply, :ok, put_in(state[:data][name], coordinates)}
  end

  def handle_call({:move, name, coordinates}, _from, state) do
    if outside?(state.jurisdiction, coordinates) do
      join(name, coordinates)

      {:reply, :ok, %{state | data: Map.delete(state.data, name)}}
     else
      {:reply, :ok, put_in(state[:data][name], coordinates)}
    end
  end

  def join(name, coordinates),
    do: GenServer.call(name(coordinates), {:join, name, coordinates})

  def move(name, previous, new),
    do: GenServer.call(name(previous), {:move, name, new})

  def name({latitude, longitude}),
    do: :"tile-#{to_integer(latitude)}-#{to_integer(longitude)}"

  defp outside?({lat1, lng1}, {lat2, lng2}) do
    tile_size = Application.get_env(:xuber, :tile_size)

    to_integer(lat2) > to_integer(lat1+tile_size) ||
    to_integer(lng2) > to_integer(lng1+tile_size)
  end

  defp to_integer(n) when is_integer(n),
    do: n
  defp to_integer(float) when is_float(float),
    do: float |> Float.floor |> round
end
