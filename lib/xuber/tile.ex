defmodule XUber.Tile do
  use GenServer

  alias XUber.{Coordinates, Grid}

  def start_link(name, coordinates) do
    state = %{
      jurisdiction: coordinates,
      pids: %{},
    }

    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:join, pid, coordinates}, _from, state) do
    record = %{
      position: coordinates,
      ref: Process.monitor(pid)
    }

    {:reply, :ok, put_in(state[:pids][pid], record)}
  end

  def handle_call({:leave, pid}, _from, state) do
    {:reply, :ok, remove(state, pid)}
  end

  def handle_call({:update, pid, coordinates}, _from, state) do
    if Coordinates.outside?(state.jurisdiction, coordinates) do
      Grid.join(pid, coordinates)

      {:reply, :ok, remove(state, pid)}
     else
      {:reply, :ok, put_in(state[:pids][pid][:position], coordinates)}
    end
  end

  def handle_call({:nearby, {lat1, lng1}, radius, options}, _from, state) do
    results = state.pids
              |> Enum.into([])
              |> Enum.filter(fn {pid, %{position: {lat2, lng2}}} ->
                :math.sqrt(:math.pow(lat2 - lat1, 2) + :math.pow(lng2 - lng1, 2)) < radius
              end)
              |> Enum.map(fn {pid, _position} -> pid end)

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
