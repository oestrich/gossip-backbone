defmodule Backbone.Events do
  @moduledoc """
  Context for caching remote events for a game
  """

  @type opts :: Keyword.t()

  import Ecto.Query

  alias Backbone.Events.Event
  alias Backbone.Games
  alias Backbone.RemoteSchema
  alias Backbone.Settings

  @repo Application.get_env(:backbone, :repo)

  def all(game) do
    Event
    |> where([e], e.game_id == ^game.id)
    |> order_by([e], desc: e.start_date, desc: e.end_date)
    |> @repo.all()
  end

  def recent(game) do
    last_week = Timex.now() |> Timex.shift(weeks: -1)

    Event
    |> where([e], e.game_id == ^game.id)
    |> where([e], e.start_date >= ^last_week)
    |> order_by([e], asc: e.start_date, asc: e.end_date)
    |> @repo.all()
  end

  def get_by(opts) do
    case @repo.get_by(Event, opts) do
      nil ->
        {:error, :not_found}

      event ->
        {:ok, event}
    end
  end

  @doc """
  Cache remote events

  Create or update remote events
  """
  def cache_remote(versions) do
    versions
    |> Settings.mark_sync()
    |> Enum.each(&cache_event/1)

    :ok
  end

  @doc false
  def cache_event(version) do
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

      case @repo.get_by(Event, remote_id: remote_id) do
        nil ->
          create_event(game, attributes)

        event ->
          update_event(event, attributes)
      end
    end
  end

  defp create_event(game, attributes) do
    game
    |> Ecto.build_assoc(:events)
    |> Event.changeset(attributes)
    |> @repo.insert()
  end

  defp update_event(event, attributes) do
    event
    |> Event.changeset(attributes)
    |> @repo.update()
  end

  @doc false
  def cache_delete(version) do
    payload = version["payload"]

    with {:ok, event} <- get_by(remote_id: payload["id"]) do
      event
      |> Event.deleted_changeset()
      |> @repo.update()
    end
  end
end
