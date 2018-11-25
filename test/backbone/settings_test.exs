defmodule Backbone.SettingsTest do
  use Backbone.DataCase

  alias Backbone.Settings

  describe "marking highest seen event" do
    test "no highest yet" do
      {:ok, highest} = Settings.mark_sync(Timex.now())

      assert highest.value
    end

    test "higher than previous" do
      now = Timex.now()

      {:ok, _highest} = Settings.mark_sync(Timex.shift(now, hours: -1))
      {:ok, highest} = Settings.mark_sync(now)

      {:ok, time} = Timex.parse(highest.value, "{ISO:Extended}")
      assert time == now
    end

    test "lower than previous" do
      now = Timex.now()

      {:ok, _highest} = Settings.mark_sync(now)
      {:ok, highest} = Settings.mark_sync(Timex.shift(now, hours: -1))

      {:ok, time} = Timex.parse(highest.value, "{ISO:Extended}")
      assert time == now
    end
  end
end
