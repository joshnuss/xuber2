defmodule XUber.DispatcherSupervisor do
  use DynamicSupervisor

  alias XUber.{
    DB,
    Dispatcher
  }

  @name __MODULE__

  def start_link(_),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: @name)

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(passenger, user, from, to) do
    {:ok, request} = DB.create_request(user.name, from, to)

    DynamicSupervisor.start_child(@name, {Dispatcher, [passenger, request]})
  end
end
