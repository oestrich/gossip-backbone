defmodule Backbone.Repo.Migrations.CreateAchievements do
  use Ecto.Migration

  def change do
    create table(:achievements) do
      add(:remote_id, :integer, null: false)
      add(:game_id, references(:games), null: false)
      add(:title, :text, null: false)
      add(:description, :text)
      add(:display, :boolean, default: true, null: false)
      add(:points, :integer, null: false)
      add(:partial_progress, :boolean, default: false, null: false)
      add(:total_progress, :integer)
      add(:is_deleted, :boolean, default: false, null: false)

      timestamps()
    end

    create index(:achievements, :game_id)
  end
end
