defmodule XUber.Coordinates do
  defp outside?({lat1, lng1}, {lat2, lng2}, bounds) do
    to_integer(lat2) > to_integer(lat1+bounds) ||
    to_integer(lng2) > to_integer(lng1+bounds)
  end

  defp to_integer(n) when is_integer(n),
    do: n
  defp to_integer(float) when is_float(float),
    do: float |> Float.floor |> round
end
