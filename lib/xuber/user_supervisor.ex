defmodule XUber.UserSupervisor do
  use DynamicSupervisor

  alias XUber.{User, Passenger, Driver}

  def start_link(_),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: XUber.UserSupervisor)

  def init(:ok),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(user=%User{type: :passenger}, coordinates),
    do: do_start_child({Passenger, [user, coordinates]})

  def start_child(user=%User{type: :driver}, coordinates),
    do: do_start_child({Driver, [user, coordinates]})

  defp do_start_child(child_spec),
    do: DynamicSupervisor.start_child(__MODULE__, child_spec)
end
