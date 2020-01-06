# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :project42,
  ecto_repos: [Project42.Repo]

# Configures the endpoint
config :project42, Project42Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "amzRkrrAE8y8igZop6VSQi2fLQ8uBbSY5tobOnHzYHAyhoIG95AMKxKJyu6CT8Vn",
  render_errors: [view: Project42Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Project42.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
