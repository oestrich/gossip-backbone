defmodule Backbone.Repo do
  use Ecto.Repo,
    otp_app: :backbone,
    adapter: Ecto.Adapters.Postgres
end
