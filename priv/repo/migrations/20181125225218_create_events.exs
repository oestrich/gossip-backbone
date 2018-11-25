defmodule Backbone.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add(:remote_id, :integer, null: false)
      add(:title, :text, null: false)
      add(:description, :text)
      add(:start_date, :date, null: false)
      add(:end_date, :date, null: false)
      add(:game_id, references(:games), null: false)
      add(:is_deleted, :boolean, default: false, null: false)

      timestamps()
    end

    create index(:events, :game_id)
  end
end
