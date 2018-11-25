defmodule Backbone.Settings.Setting do
  @moduledoc """
  Schema for settings
  """

  use Backbone.Schema

  schema "settings" do
    field(:name, :string)
    field(:value, :string)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [ :name, :value])
    |> validate_required([:name, :value])
  end
end
