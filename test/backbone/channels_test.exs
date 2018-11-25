defmodule Backbone.ChannelsTest do
  use Backbone.DataCase

  alias Backbone.Channels

  describe "sync remote channels" do
    test "creates local copies" do
      :ok = Channels.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "name" => "gossip",
            "description" => nil,
            "hidden" => true
          }
        }
      ])

      assert length(Channels.all(include_hidden: true)) == 1
    end

    test "creates local copies, handles updates" do
      :ok = Channels.cache_remote([
        %{
          "action" => "create",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "name" => "gossip",
            "description" => nil,
            "hidden" => true
          }
        }
      ])

      :ok = Channels.cache_remote([
        %{
          "action" => "update",
          "logged_at" => "2018-11-24T12:00:00Z",
          "payload" => %{
            "id" => 1,
            "name" => "gossip",
            "description" => "updated",
            "hidden" => true
          }
        }
      ])

      assert length(Channels.all(include_hidden: true)) == 1

      {:ok, channel} = Channels.get("gossip")
      assert channel.description == "updated"
    end
  end
end
