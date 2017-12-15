defmodule XUber.DispatcherSupervisor do
  use Supervisor

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.DispatcherSupervisor)

  def init(:ok) do
    Supervisor.init([XUber.Dispatcher], strategy: :simple_one_for_one)
  end
end
