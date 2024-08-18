defmodule Skanny.Repo do
  use Ecto.Repo,
    otp_app: :skanny,
    adapter: Ecto.Adapters.Postgres
end
