defmodule XUber.UserSupervisor do
  use Supervisor

  def start_link(_),
    do: Supervisor.start_link(__MODULE__, :ok, name: XUber.UserSupervisor)

  def init(:ok) do
    children = [
      {XUber.Passenger, []},
      {XUber.Driver, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
