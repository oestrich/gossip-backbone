defmodule Backbone.Games do
  @moduledoc """
  Context for caching remote games from Gossip
  """

  @type opts :: Keyword.t()

  alias Backbone.Games.Connection
  alias Backbone.Games.Game
  alias Backbone.RemoteSchema

  import Ecto.Query

  @repo Application.get_env(:backbone, :repo)

  @doc """
  Get all games
  """
  @spec all(opts()) :: [Game.t()]
  def all(opts \\ []) do
    Game
    |> order_by([g], g.name)
    |> maybe_include_hidden(opts)
    |> @repo.all()
  end

  defp maybe_include_hidden(query, opts) do
    case Keyword.get(opts, :include_hidden, false) do
      false ->
        query |> where([g], g.display == true)

      true ->
        query
    end
  end

  @doc """
  Get a game by name
  """
  def get(id, opts \\ []) do
    case @repo.get_by(Game, Keyword.merge(opts, [id: id])) do
      nil ->
        {:error, :not_found}

      game ->
        {:ok, game}
    end
  end

  @doc """
  Get a game by name
  """
  def get_by(opts) do
    case @repo.get_by(Game, opts) do
      nil ->
        {:error, :not_found}

      game ->
        {:ok, game}
    end
  end

  @doc """
  Get a game by name
  """
  def get_by_name(name, opts \\ []) do
    case @repo.get_by(Game, Keyword.merge(opts, [short_name: name])) do
      nil ->
        {:error, :not_found}

      game ->
        {:ok, game}
    end
  end

  @doc """
  Cache remote games

  Create or update remote games
  """
  def cache_remote(games) do
    Enum.each(games, &cache_game/1)

    :ok
  end

  @doc false
  def cache_game(attributes) do
    remote_id = Map.get(attributes, "id")

    attributes = RemoteSchema.map_fields(attributes, %{
      "id" => "remote_id",
      "game" => "short_name",
      "display_name" => "name",
    })

    case @repo.get_by(Game, remote_id: remote_id) do
      nil ->
        create_game(attributes)

      game ->
        update_game(game, attributes)
    end
  end

  defp create_game(attributes) do
    %Game{}
    |> Game.changeset(attributes)
    |> @repo.insert()
  end

  defp update_game(game, attributes) do
    connections = Map.get(attributes, "connections", [])
    attributes = Map.delete(attributes, "connections")
    changeset = game |> Game.changeset(attributes)

    with {:ok, game} <- @repo.update(changeset) do
      update_connections(game, connections)
    end
  end

  # Find connections to
  # - Update
  # - Delete
  # - Create
  defp update_connections(game, connections) do
    changesets =
      game
      |> create_connection_changesets(connections)
      |> update_connection_changesets(game, connections)
      |> delete_connection_changesets(game, connections)

    game
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:connections, changesets)
    |> @repo.update()
  end

  defp create_connection_changesets(game, connections) do
    connection_ids = Enum.map(game.connections, &(&1.id))
    create_connections = Enum.reject(connections, fn connection ->
      connection["id"] in connection_ids
    end)

    Enum.map(create_connections, fn connection ->
      Connection.changeset(%Connection{}, connection)
    end)
  end

  defp update_connection_changesets(changesets, game, connections) do
    connection_ids = Enum.map(connections, &(&1["id"]))
    update_connections = Enum.filter(game.connections, fn connection ->
      connection.id in connection_ids
    end)

    Enum.reduce(update_connections, changesets, fn connection, changesets ->
      attributes = Enum.find(connections, &(&1["id"] == connection.id))
      [Connection.changeset(connection, attributes) | changesets]
    end)
  end

  defp delete_connection_changesets(changesets, game, connections) do
    connection_ids = Enum.map(connections, &(&1["id"]))
    delete_connections = Enum.reject(game.connections, fn connection ->
      connection.id in connection_ids
    end)

    Enum.reduce(delete_connections, changesets, fn connection, changesets ->
      changeset = Ecto.Changeset.change(connection)
      [%{changeset | action: :delete} | changesets]
    end)
  end
end
