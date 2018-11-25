defmodule Backbone.Sync do
  @moduledoc """
  Sync remote models to the local db
  """

  alias Backbone.Channels
  alias Backbone.Games

  def trigger_sync(since \\ nil) do
    event = %{
      "event" => "sync",
      "payload" => %{
        "since" => since
      }
    }

    WebSockex.cast(Gossip.Socket, {:send, event})
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
end
