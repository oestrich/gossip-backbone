defmodule Backbone.Repo.Migrations.NullFalseAchievementsKey do
  use Ecto.Migration

  def change do
    alter table(:achievements) do
      modify(:key, :uuid, null: false)
    end
  end
end
