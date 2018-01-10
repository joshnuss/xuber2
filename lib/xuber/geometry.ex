defmodule XUber.Geometry do
  @tile_size Application.get_env(:xuber, :tile_size)

  def outside?({x1, y1}, {x2, y2}) do
    to_integer(x2) > to_integer(x1+@tile_size) ||
    to_integer(y2) > to_integer(y1+@tile_size)
  end

  def distance({x1, y1}, {x2, y2}) do
    :math.sqrt(square(x2 - x1) + square(y2 - y1))
  end

  defp to_integer(n) when is_integer(n),
    do: n
  defp to_integer(float) when is_float(float),
    do: float |> Float.floor |> round

  defp square(n),
    do: :math.pow(n, 2)
end
