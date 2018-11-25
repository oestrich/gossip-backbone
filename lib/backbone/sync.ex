defmodule Backbone.Sync do
  @moduledoc """
  Sync remote models to the local db
  """

  alias Backbone.Channels
  alias Backbone.Events
  alias Backbone.Games
  alias Backbone.Settings

  def trigger_sync() do
    event = %{
      "event" => "sync",
      "payload" => %{
        "since" => last_synced_at()
      }
    }

    WebSockex.cast(Gossip.Socket, {:send, event})
  end

  defp last_synced_at() do
    with {:ok, last_synced_at} <- Settings.last_synced_at() do
      {:ok, last_synced_at_timestamp} = Timex.parse(last_synced_at.value, "{ISO:Extended}")
      last_synced_at_timestamp
    else
      {:error, :not_found} ->
        nil
    end
  end

  def sync_channels(state, event) do
    with {:ok, versions} <- Map.fetch(event, "payload") do
      Channels.cache_remote(versions)

      channels =
        Enum.reduce(versions, state.channels, fn version, channels ->
          channel = version.payload
          [channel["name"] | channels]
        end)

      channels = Enum.uniq(channels)

      {:ok, %{state | channels: channels}}
    else
      _ ->
        {:ok, state}
    end
  end

  def sync_games(event) do
    with {:ok, versions} <- Map.fetch(event, "payload") do
      Games.cache_remote(versions)
    end
  end

  def sync_events(event) do
    with {:ok, versions} <- Map.fetch(event, "payload") do
      Events.cache_remote(versions)
    end
  end
end
