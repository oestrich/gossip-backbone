defmodule Backbone.GamesTest do
  use Backbone.DataCase

  alias Backbone.Games

  describe "sync remote games" do
    test "creates local copies" do
      :ok = Games.cache_remote([
        %{
          "id" => 1,
          "game" => "gossip",
          "display_name" => "Gossip",
          "display" => true,
          "client_id" => "UUID",
          "client_secret" => "UUID",
        }
      ])

      assert length(Games.all()) == 1
    end

    test "creates local copies, handles updates" do
      :ok = Games.cache_remote([
        %{
          "id" => 1,
          "game" => "gossip",
          "display_name" => "Gossip",
          "display" => true,
          "client_id" => "UUID",
          "client_secret" => "UUID",
        }
      ])

      :ok = Games.cache_remote([
        %{
          "id" => 1,
          "game" => "gossip",
          "display_name" => "Updated",
          "display" => true,
          "client_id" => "UUID",
          "client_secret" => "UUID",
        }
      ])

      assert length(Games.all()) == 1

      {:ok, game} = Games.get_by_name("gossip")
      assert game.name == "Updated"
    end

    test "copies connections over" do
      :ok = Games.cache_remote([
        %{
          "id" => 1,
          "game" => "gossip",
          "display_name" => "Gossip",
          "display" => true,
          "client_id" => "UUID",
          "client_secret" => "UUID",
          "connections" => [
            %{"type" => "web", "url" => "https://example.com/play"},
            %{"type" => "telnet", "host" => "example.com", "port" => 4000},
            %{"type" => "secure telnet", "host" => "example.com", "port" => 4000},
          ]
        }
      ])

      {:ok, game} = Games.get_by_name("gossip")
      assert length(game.connections) == 3
    end

    test "updates connections" do
      connection = %{"id" => UUID.uuid4(), "type" => "web", "url" => "https://example.com/play"}

      game = %{
        "id" => 1,
        "game" => "gossip",
        "display_name" => "Gossip",
        "display" => true,
        "client_id" => "UUID",
        "client_secret" => "UUID",
        "connections" => [connection]
      }

      :ok = Games.cache_remote([game])

      game = %{
        "id" => 1,
        "game" => "gossip",
        "display_name" => "Gossip",
        "display" => true,
        "client_id" => "UUID",
        "client_secret" => "UUID",
        "connections" => [
          connection,
          %{"id" => UUID.uuid4(), "type" => "telnet", "host" => "example.com", "port" => 4000},
        ]
      }

      :ok = Games.cache_remote([game])

      {:ok, game} = Games.get_by_name("gossip")
      assert length(game.connections) == 2
    end

    test "deletes connections" do
      game = %{
        "id" => 1,
        "game" => "gossip",
        "display_name" => "Gossip",
        "display" => true,
        "client_id" => "UUID",
        "client_secret" => "UUID",
        "connections" => [
          %{"id" => UUID.uuid4(), "type" => "web", "url" => "https://example.com/play"},
          %{"id" => UUID.uuid4(), "type" => "secure telnet", "host" => "example.com", "port" => 4000},
        ]
      }

      :ok = Games.cache_remote([game])

      game = %{
        "id" => 1,
        "game" => "gossip",
        "display_name" => "Gossip",
        "display" => true,
        "client_id" => "UUID",
        "client_secret" => "UUID",
        "connections" => []
      }

      :ok = Games.cache_remote([game])

      {:ok, game} = Games.get_by_name("gossip")
      assert length(game.connections) == 0
    end
  end
end
