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
  def last_synced_at() do
    case @repo.get_by(Setting, name: @last_synced_at) do
      nil ->
        {:error, :not_found}

      last_synced_at ->
        {:ok, last_synced_at}
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
    case last_synced_at() do
      {:error, :not_found} ->
        highest = Timex.format!(highest, "{ISO:Extended}")

        %Setting{}
        |> Setting.changeset(%{name: @last_synced_at, value: highest})
        |> @repo.insert()

      {:ok, last_synced_at} ->
        {:ok, last_synced_at_timestamp} = Timex.parse(last_synced_at.value, "{ISO:Extended}")

        case Timex.after?(highest, last_synced_at_timestamp) do
          true ->
            highest = Timex.format!(highest, "{ISO:Extended}")

            last_synced_at
            |> Setting.changeset(%{value: highest})
            |> @repo.update()

          false ->
            {:ok, last_synced_at}
        end
    end
  end
end
