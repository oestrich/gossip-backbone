defmodule Backbone.AchievementsTest do
  use Backbone.DataCase

  alias Backbone.Achievements

  describe "sync remote achievements" do
    test "creates local copies" do
      game = cache_game()

      :ok = Achievements.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Achievement",
            "game_id" => game.remote_id,
            "description" => "An achievement",
            "display" => true,
            "points" => 10,
            "partial_progress" => false,
            "total_progress" => nil
          },
        }
      ])

      assert length(Achievements.all(game)) == 1
    end

    test "creates local copies, handles updates" do
      game = cache_game()

      :ok = Achievements.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Achievement",
            "game_id" => game.remote_id,
            "description" => "An achievement",
            "display" => true,
            "points" => 10,
            "partial_progress" => false,
            "total_progress" => nil
          },
        }
      ])

      :ok = Achievements.cache_remote([
        %{
          "action" => "update",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Updated",
            "game_id" => game.remote_id,
            "description" => "An achievement",
            "display" => true,
            "points" => 10,
            "partial_progress" => false,
            "total_progress" => nil
          },
        }
      ])

      assert length(Achievements.all(game)) == 1

      {:ok, achievement} = Achievements.get_by(remote_id: 1)
      assert achievement.title == "Updated"
    end

    test "handles deletions" do
      game = cache_game()

      :ok = Achievements.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Achievement",
            "game_id" => game.remote_id,
            "description" => "An achievement",
            "display" => true,
            "points" => 10,
            "partial_progress" => false,
            "total_progress" => nil
          },
        }
      ])

      :ok = Achievements.cache_remote([
        %{
          "action" => "delete",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "title" => "Updated",
            "game_id" => game.remote_id,
            "description" => "An achievement",
            "display" => true,
            "points" => 10,
            "partial_progress" => false,
            "total_progress" => nil
          },
        }
      ])

      assert length(Achievements.all(game)) == 0

      {:ok, achievement} = Achievements.get_by(remote_id: 1)
      assert achievement.is_deleted
    end
  end
end
