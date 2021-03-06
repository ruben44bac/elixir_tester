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
  pubsub: [name: GuiltySparkWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "8ioYmdljKIFwiDFYfrE25aHtzCpU4GdfRgLMt2NZdKmz+vexrFQdPbk2sXOINL7t"
  ]


config :fcmex,
  server_key: "AAAA9Ej_qEE:APA91bGbOLmEH3DFWt8mFZpB3nyEOUdmW9CGVl3zr-6ZJotEUihVWlhWeZ8neSzSEyMaeAc9P3lOlUooe74oMBIDrPdd9JRoDLXsDgUzfFSfk1uN_JJskHzf9ZNdBJ_MIYNZO8mKQrs5"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
