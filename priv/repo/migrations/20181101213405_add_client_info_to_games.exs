defmodule Backbone.Repo.Migrations.AddClientInfoToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add(:client_id, :text)
      add(:client_secret, :text)
    end
  end
end
