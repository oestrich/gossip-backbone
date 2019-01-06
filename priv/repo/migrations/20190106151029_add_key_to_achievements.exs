defmodule Backbone.Repo.Migrations.AddKeyToAchievements do
  use Ecto.Migration

  def change do
    alter table(:achievements) do
      add(:key, :uuid)
    end
  end
end
