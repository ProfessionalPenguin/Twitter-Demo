use Mix.Config

# Configure your database
config :project42, Project42.Repo,
  username: "postgres",
  password: "postgres",
  database: "project42_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :project42, Project42Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
