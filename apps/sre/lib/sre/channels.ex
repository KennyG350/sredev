defmodule Sre.Channels do
  @moduledoc """
    Module with common helpers to use in channels
  """

  @doc """
    Get user id from the socket
  """
  def get_user_id(%{topic: topic}) do
    [user_id] =
      topic
      |> String.split(":")
      |> Enum.take(-1)

    try do
      user_id = String.to_integer(user_id)
      {:ok, user_id}
    rescue
      ArgumentError ->
        {:error, "Not able to parse user id"}
    end
  end
end
