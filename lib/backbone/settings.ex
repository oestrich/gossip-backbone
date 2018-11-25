defmodule Backbone.Settings do
  @moduledoc """
  Track backbone settings
  """

  alias Backbone.Settings.Setting

  @repo Application.get_env(:backbone, :repo)

  @last_synced_at "last_synced_at"

  @doc """
  Retrieve the highest seen event timestamp
  """
  def highest_sync() do
    case @repo.get_by(Setting, name: @last_synced_at) do
      nil ->
        {:error, :not_found}

      highest_sync ->
        {:ok, highest_sync}
    end
  end

  @doc """
  Mark the highest logged version seen in a sync eventc
  """
  def mark_sync(versions) when is_list(versions) do
    versions
    |> Enum.map(fn version ->
      Timex.parse!(version["logged_at"], "{ISO:Extended}")
    end)
    |> Enum.max()
    |> mark_sync()

    versions
  end

  def mark_sync(highest) do
    case highest_sync() do
      {:error, :not_found} ->
        highest = Timex.format!(highest, "{ISO:Extended}")

        %Setting{}
        |> Setting.changeset(%{name: @last_synced_at, value: highest})
        |> @repo.insert()

      {:ok, highest_sync} ->
        {:ok, last_synced_at} = Timex.parse(highest_sync.value, "{ISO:Extended}")

        case Timex.after?(highest, last_synced_at) do
          true ->
            highest = Timex.format!(highest, "{ISO:Extended}")

            highest_sync
            |> Setting.changeset(%{value: highest})
            |> @repo.update()

          false ->
            {:ok, highest_sync}
        end
    end
  end
end
