defmodule XUber.Geometry do
  def outside?(bounds, coordinates),
    do: !inside?(bounds, coordinates)

  def inside?({{x1, y1}, {x2, y2}}, {x, y}) do
    to_integer(x) >= to_integer(x1) && to_integer(x) < to_integer(x2) &&
      to_integer(y) >= to_integer(y1) && to_integer(y) < to_integer(y2)
  end

  def distance({x1, y1}, {x2, y2}) do
    :math.sqrt(square(x2 - x1) + square(y2 - y1))
  end

  defp to_integer(n) when is_integer(n),
    do: n

  defp to_integer(float) when is_float(float),
    do: float |> Float.floor() |> round

  defp square(n),
    do: :math.pow(n, 2)
end
