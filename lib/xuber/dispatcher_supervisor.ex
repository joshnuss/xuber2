defmodule XUber.DispatcherSupervisor do
  use DynamicSupervisor

  alias XUber.Dispatcher

  @name __MODULE__

  def start_link(_),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: @name)

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(passenger, coordinates) do
    DynamicSupervisor.start_child(@name, {Dispatcher, [passenger, coordinates]})
  end
end
