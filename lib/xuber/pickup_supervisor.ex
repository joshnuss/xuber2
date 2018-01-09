defmodule XUber.PickupSupervisor do
  use DynamicSupervisor

  alias XUber.Pickup

  @name __MODULE__

  def start_link(_),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: @name)

  def init(:ok),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(driver, passenger, coordinates) do
    DynamicSupervisor.start_child(@name, {Pickup, [driver, passenger, coordinates]})
  end
end
