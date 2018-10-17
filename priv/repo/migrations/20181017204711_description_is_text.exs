defmodule Backbone.Repo.Migrations.DescriptionIsText do
  use Ecto.Migration

  def change do
    alter table(:games) do
      modify(:name, :text)
      modify(:short_name, :text)
      modify(:user_agent, :text)
      modify(:user_agent_url, :text)
      modify(:description, :text)
      modify(:homepage_url, :text)
    end
  end
end
