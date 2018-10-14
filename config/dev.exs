use Mix.Config

config :backbone, Backbone.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "backbone_dev",
  hostname: "localhost"
