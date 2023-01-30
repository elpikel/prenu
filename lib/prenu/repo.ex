defmodule Prenu.Repo do
  use Ecto.Repo,
    otp_app: :prenu,
    adapter: Ecto.Adapters.Postgres
end
