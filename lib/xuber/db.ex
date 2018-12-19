defmodule XUber.DB do
  use Ecto.Repo,
    otp_app: :xuber,
    adapter: Ecto.Adapters.Postgres
end
