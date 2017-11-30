defmodule Sre.UserSuggestion do
  @moduledoc """
    Handle fetching the User agent suggestions.
  """

  import Ecto.Query, only: [from: 2]

  alias Schema.{Repo, Resource.Listing}

  def fetch(user_id) do
      user_id
      |> suggestions_query
      |> Repo.all
  end

  defp suggestions_query(user_id) do
    from i in Listing,
      join: g in assoc(i, :groups),
      where: g.user_id == ^user_id and g.name != "Favorites" and g.created_by != ^user_id,
      preload: [:photos]
  end
end
