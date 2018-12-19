defmodule XUber.Tile do
  use GenServer

  alias XUber.{Geometry, Grid}

  @tile_size Application.get_env(:xuber, :tile_size)

  def start_link(name, coordinates = {lat, lng}) do
    state = %{
      jurisdiction: {coordinates, {lat + @tile_size, lng + @tile_size}},
      pids: %{}
    }

    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:join, pid, coordinates, traits}, _from, state) do
    record = %{
      position: coordinates,
      traits: traits,
      ref: Process.monitor(pid)
    }

    {:reply, :ok, put_in(state[:pids][pid], record)}
  end

  def handle_call({:leave, pid}, _from, state) do
    {:reply, :ok, remove(state, pid)}
  end

  def handle_call({:update, pid, coordinates}, _from, state) do
    if Geometry.outside?(state.jurisdiction, coordinates) do
      Grid.join(pid, coordinates)

      {:reply, :ok, remove(state, pid)}
    else
      {:reply, :ok, put_in(state[:pids][pid][:position], coordinates)}
    end
  end

  def handle_call({:nearby, from, radius, filters}, _from, state) do
    results =
      state.pids
      |> Enum.into([])
      |> Enum.filter(fn {_pid, %{traits: traits}} -> filters -- traits == [] end)
      |> Enum.map(fn {pid, %{position: to}} -> {pid, to, Geometry.distance(from, to)} end)
      |> Enum.filter(fn {_pid, _position, distance} -> distance < radius end)

    {:reply, {:ok, results}, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {:noreply, remove(state, pid)}
  end

  defp remove(state, pid) do
    Process.demonitor(state.pids[pid].ref)

    %{state | pids: Map.delete(state.pids, pid)}
  end
end
