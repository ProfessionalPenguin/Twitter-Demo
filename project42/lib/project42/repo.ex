defmodule Project42.Repo do
  use Ecto.Repo,
    otp_app: :project42,
    adapter: Ecto.Adapters.Postgres
end
