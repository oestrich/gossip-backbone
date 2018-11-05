use Mix.Config

config :logger, :level, :warn

config :backbone, Backbone.Repo,
  database: "backbone_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
