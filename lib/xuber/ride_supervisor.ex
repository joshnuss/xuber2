defmodule XUber.RideSupervisor do
  use Supervisor

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.RideSupervisor)

  def init(:ok) do
    children = [
      {XUber.Ride, []}
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
