defmodule XUber.PickupSupervisor do
  use Supervisor

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.PickupSupervisor)

  def init(:ok) do
    children = [
      {XUber.Pickup, []}
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
