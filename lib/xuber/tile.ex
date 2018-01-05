defmodule XUber.Tile do
  use GenServer

  def start_link(name, coordinates) do
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
      Grid.leave(pid, coordinates)
      Grid.join(pid, coordinates)

      {:reply, :ok, state}
     else
      {:reply, :ok, put_in(state[:data][pid], coordinates)}
    end
  end
end
