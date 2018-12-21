defmodule XUber.RideSupervisor do
  use DynamicSupervisor

  alias XUber.{
    DB,
    Ride
  }

  @name __MODULE__

  def start_link(_),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: @name)

  def init(:ok),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(pickup, passenger, driver) do
    {:ok, ride} = DB.create_ride(pickup)

    DynamicSupervisor.start_child(@name, {Ride, [ride, passenger, driver]})
  end
end
