defmodule XUber.Coordinates do
  @tile_size Application.get_env(:xuber, :tile_size)

  def outside?({lat1, lng1}, {lat2, lng2}) do
    to_integer(lat2) > to_integer(lat1+@tile_size) ||
    to_integer(lng2) > to_integer(lng1+@tile_size)
  end

  defp to_integer(n) when is_integer(n),
    do: n
  defp to_integer(float) when is_float(float),
    do: float |> Float.floor |> round
end
