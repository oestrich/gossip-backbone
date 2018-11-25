defmodule Backbone.Events.Event do
  @moduledoc """
  Schema for remote events
  """

  use Backbone.Schema

  alias Backbone.Games.Game

  schema "events" do
    field(:remote_id, :integer)
    field(:title, :string)
    field(:description, :string)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:is_deleted, :boolean)

    belongs_to(:game, Game)

    timestamps()
  end

  @fields [
    :remote_id,
    :title,
    :description,
    :start_date,
    :end_date,
  ]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required([:remote_id, :title, :start_date, :end_date])
  end

  def deleted_changeset(struct) do
    struct
    |> change()
    |> put_change(:is_deleted, true)
  end
end
