# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :guiltySpark,
  ecto_repos: [GuiltySpark.Repo]

config :guiltySpark_web,
  ecto_repos: [GuiltySpark.Repo],
  generators: [context_app: :guiltySpark]

# Configures the endpoint
config :guiltySpark_web, GuiltySparkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yv90wiqGMyCZ0KV/MxVe7oAnA3hD6VVHhBM4mL+GzAkAT5fccmT4z9b56ESvKuUe",
  render_errors: [view: GuiltySparkWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GuiltySparkWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
