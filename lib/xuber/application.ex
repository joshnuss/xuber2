defmodule XUber.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      XUber.Grid,
      XUber.UserSupervisor,
      XUber.DispatcherSupervisor,
      XUber.PickupSupervisor,
      XUber.RideSupervisor,
    ]

    opts = [strategy: :one_for_one, name: XUber.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
