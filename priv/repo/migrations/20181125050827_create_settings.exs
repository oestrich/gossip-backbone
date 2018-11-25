defmodule Backbone.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add(:name, :string, null: false)
      add(:value, :text, null: false)

      timestamps()
    end
  end
end
