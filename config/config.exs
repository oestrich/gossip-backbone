use Mix.Config

config :backbone, ecto_repos: [Backbone.Repo]
config :backbone, repo: Backbone.Repo

import_config("#{Mix.env}.exs")
