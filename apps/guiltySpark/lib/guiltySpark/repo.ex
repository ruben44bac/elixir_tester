defmodule GuiltySpark.Repo do
  use Ecto.Repo,
    otp_app: :guiltySpark,
    adapter: Ecto.Adapters.Postgres
end
