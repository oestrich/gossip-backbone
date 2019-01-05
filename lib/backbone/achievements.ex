defmodule Backbone.Achievements do
  @moduledoc """
  Context for caching remote achievements for a game
  """

  @type opts :: Keyword.t()

  import Ecto.Query

  alias Backbone.Achievements.Achievement
  alias Backbone.Games
  alias Backbone.RemoteSchema
  alias Backbone.Settings

  @repo Application.get_env(:backbone, :repo)

  def all(game) do
    Achievement
    |> where([a], a.game_id == ^game.id)
    |> order_by([a], asc: a.title)
    |> @repo.all()
  end

  def get_by(opts) do
    case @repo.get_by(Achievement, opts) do
      nil ->
        {:error, :not_found}

      achievement ->
        {:ok, achievement}
    end
  end

  @doc """
  Cache remote achievements

  Create or update remote achievements
  """
  def cache_remote(versions) do
    versions
    |> Settings.mark_sync()
    |> Enum.each(&cache_achievement/1)

    :ok
  end

  @doc false
  def cache_achievement(version) do
    case version["action"] do
      "create" ->
        cache_upsert(version)

      "update" ->
        cache_upsert(version)

      "delete" ->
        cache_delete(version)
    end
  end

  @doc false
  def cache_upsert(version) do
    attributes = version["payload"]
    remote_id = Map.get(attributes, "id")
    game_id = Map.get(attributes, "game_id")

    with {:ok, game} <- Games.get_by(remote_id: game_id) do
      attributes = RemoteSchema.map_fields(attributes, %{
        "id" => "remote_id",
      })

      case @repo.get_by(Achievement, remote_id: remote_id) do
        nil ->
          create_achievement(game, attributes)

        achievement ->
          update_achievement(achievement, attributes)
      end
    end
  end

  defp create_achievement(game, attributes) do
    game
    |> Ecto.build_assoc(:achievements)
    |> Achievement.changeset(attributes)
    |> @repo.insert()
  end

  defp update_achievement(achievement, attributes) do
    achievement
    |> Achievement.changeset(attributes)
    |> @repo.update()
  end

  @doc false
  def cache_delete(version) do
    payload = version["payload"]

    with {:ok, achievement} <- get_by(remote_id: payload["id"]) do
      achievement
      |> Achievement.deleted_changeset()
      |> @repo.update()
    end
  end
end
