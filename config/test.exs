use Mix.Config

config :logger, :level, :warn

config :backbone, Backbone.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "backbone_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
