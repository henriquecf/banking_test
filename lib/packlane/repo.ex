defmodule Packlane.Repo do
  use Ecto.Repo,
    otp_app: :packlane,
    adapter: Ecto.Adapters.Postgres
end
