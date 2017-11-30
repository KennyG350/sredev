defmodule Leads do
  @moduledoc """
  Model for interacting with leads
  """
  import Ecto.Query
  alias Ecto.Changeset

  alias Schema.{
    Repo,
    Resource.Listing,
    Resource.Lead,
    Resource.User
  }

  @doc """
    save a lead given the lsiting id and the user id
  """

  def save_lead(status, {:buyer, user_id}) do
    user =
      User
      |> Repo.get(user_id)
      |> Repo.preload(:leads)

    case length(user.leads) do
      0 -> save_new_lead(status, user)
      _ ->
        if Enum.all?(user.leads, & &1.status == "archived") do
          save_new_lead(status, user)
        else
          :ok
        end
    end
  end

  def save_new_lead(status, user) do
    lead =
      %Lead{}
      |> Lead.changeset(%{status: status, lead_type: "buyer"})
      |> Repo.insert!
      |> Repo.preload(:users)

    lead
    |> Listing.changeset
    |> Changeset.put_assoc(:users, Enum.map(lead.users ++ [user], &Changeset.change/1))
    |> Repo.update!
    |> update_relationship(user)
  end

  defp update_relationship(lead, user) do
    query = from(lu in "leads_users", where: [lead_id: ^lead.id, user_id: ^user.id, relationship: is_nil(lu.relationship)])

    Repo.update_all(query, set: [relationship: "self"])
  end
end
