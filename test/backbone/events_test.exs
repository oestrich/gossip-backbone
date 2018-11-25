defmodule Backbone.EventsTest do
  use Backbone.DataCase

  alias Backbone.Events

  describe "sync remote events" do
    test "creates local copies" do
      game = cache_game()

      :ok = Events.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Event",
            "game_id" => game.remote_id,
            "start_date" => "2018-11-20",
            "end_date" => "2018-11-21"
          },
        }
      ])

      assert length(Events.all(game)) == 1
    end

    test "creates local copies, handles updates" do
      game = cache_game()

      :ok = Events.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Event",
            "game_id" => game.remote_id,
            "start_date" => "2018-11-20",
            "end_date" => "2018-11-21"
          },
        }
      ])

      :ok = Events.cache_remote([
        %{
          "action" => "update",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Updated",
            "game_id" => game.remote_id,
            "start_date" => "2018-11-20",
            "end_date" => "2018-11-21"
          },
        }
      ])

      assert length(Events.all(game)) == 1

      {:ok, event} = Events.get_by(remote_id: 1)
      assert event.title == "Updated"
    end

    test "handles deletions" do
      game = cache_game()

      :ok = Events.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Event",
            "game_id" => game.remote_id,
            "start_date" => "2018-11-20",
            "end_date" => "2018-11-21"
          },
        }
      ])

      :ok = Events.cache_remote([
        %{
          "action" => "delete",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Updated",
            "game_id" => game.remote_id,
            "start_date" => "2018-11-20",
            "end_date" => "2018-11-21"
          },
        }
      ])

      assert length(Events.all(game)) == 1

      {:ok, event} = Events.get_by(remote_id: 1)
      assert event.is_deleted
    end
  end
end
