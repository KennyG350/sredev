defmodule User.Activity do
  @moduledoc """
    A module to update the user_activities table for various user activities
  """
  use GenServer
  import Ecto.Query

  alias Schema.{
    Repo,
    Resource.Search,
    Resource.User,
    Resource.Listing
  }

  @server_name UserActivitesServer
  @activty_keys [:entity_type, :activity_type, :message]

  ## Client Code

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @server_name)
  end

  @doc """
    Function to save for when a user views a listing
  """
  def viewed_listing(user_id, listing_url) do
    GenServer.cast(@server_name, {:view_listing, user_id, listing_url})
  end

  ## Server Code

  def handle_cast({:view_listing, user_id, listing_url}, state) do
    user =
      user_id
      |> user_query
      |> Repo.one

    listing_url
    |> get_listing_id_by_url
    |> Repo.one
    |> build_activity({:viewed_listing, user})
    |> insert_activity

    {:noreply, state}
  end

  def handle_cast({:saved_listing, %Listing{} = listing, user_id}, state) do
    user =
      user_id
      |> user_query
      |> Repo.one

    listing
    |> build_activity({:saved_listing, user})
    |> insert_activity

    {:noreply, state}
  end

  ## Helpers

  defp build_activity(entity, {:viewed_listing, user}) do
    message = "Viewed listing with the address of: #{build_address(entity)}"

    entity
    |> base_activity(user.id)
    |> Keyword.merge(build_custom_activity_fields(["listing", "viewed_listing", message]))
  end

  defp build_custom_activity_fields(list_of_values) do
    List.zip [@activty_keys, list_of_values]
  end

  defp base_activity(entity, user_id),
    do: [entity_id: entity.id, user_id: user_id]

  defp get_listing_id_by_url(url) do
    from l in Listing,
      select: [:id, :url, :city, :state, :zip_code, :street_name, :street_number],
      where: l.url == ^url
  end

  defp insert_activity(record) do
    Repo.insert_all "user_activities", [record], returning: [:id]
  end

  defp build_address(
    %Listing{street_number: street_number, street_name: str_name, city: city, state: state, zip_code: zip}
  ) do
    "#{street_number} #{String.capitalize(str_name)} #{city}, #{state}, #{zip}"
  end

  defp user_query(user_id) do
    from u in "users",
      where: [id: ^user_id],
      select: %{id: u.id, first_name: u.first_name, last_name: u.last_name}
  end

  defp capitalize_all_street_names(street_name) do
    street_name
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.intersperse(" ")
    |> Enum.reverse
    |> Enum.reduce(&Kernel.<>/2)
  end
end
