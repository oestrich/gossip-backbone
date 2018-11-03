defmodule Backbone.Repo.Migrations.AddRedirectUrisToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add(:redirect_uris, {:array, :text}, default: fragment("'{}'"), null: false)
    end
  end
end
