defmodule Backbone.Achievements.Achievement do
  @moduledoc """
  Schema for remote achievements
  """

  use Backbone.Schema

  alias Backbone.Games.Game

  schema "achievements" do
    field(:remote_id, :integer)
    field(:title, :string)
    field(:description, :string)
    field(:display, :boolean)
    field(:points, :integer)
    field(:partial_progress, :boolean)
    field(:total_progress, :integer)
    field(:is_deleted, :boolean)

    belongs_to(:game, Game)

    timestamps()
  end

  @fields [
    :remote_id,
    :title,
    :description,
    :display,
    :points,
    :partial_progress,
    :total_progress
  ]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required([:remote_id, :title, :display, :points, :partial_progress])
  end

  def deleted_changeset(struct) do
    struct
    |> change()
    |> put_change(:is_deleted, true)
  end
end
