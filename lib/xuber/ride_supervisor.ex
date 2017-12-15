defmodule XUber.RideSupervisor do
  use Supervisor

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.RideSupervisor)

  def init(:ok) do
    Supervisor.init([XUber.Ride], strategy: :simple_one_for_one)
  end
end
