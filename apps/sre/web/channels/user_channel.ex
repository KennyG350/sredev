defmodule Sre.UserChannel do
  @moduledoc """
    Module for user actions channel
  """
  use Phoenix.Channel

  alias Group.ListingService, as: Api
  alias User.Search
  alias Sre.Channels

  alias User.Activity

  @favorites_group_name "Favorites"

  def join("user:" <> _user_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("save_search", %{"search_params" => search}, socket) do
    {:ok, user_id} = Channels.get_user_id socket
    search = URI.decode_query search
    {:ok, search, _} = Search.save_user_search user_id, search["location"], search
    push socket, "save_search_success", %{search_name: search.name}
    {:noreply, socket}
  end

  def handle_in("save_listing", %{"listing_id" => listing_id, "group_id" => group_id}, socket) do
    {:ok, _user_id} = Channels.get_user_id socket
    {:ok, _listing, _} = Api.add_listing group_id, listing_id
    {:noreply, socket}
  end

  def handle_in("favorite_listing", %{"listing_id" => listing_id}, socket) do
    {:ok, user_id} = Channels.get_user_id socket
    group = Api.fetch_by_user_id_and_name(user_id, @favorites_group_name)
    {:ok, _listing, _} = Api.add_listing group.id, listing_id

    push socket, "favorite_listing_success", %{listing_id: listing_id}
    {:noreply, socket}
  end

  def handle_in("unfavorite_listing", %{"listing_id" => listing_id}, socket) do
    {:ok, user_id} = Channels.get_user_id socket
    group = Api.fetch_by_user_id_and_name(user_id, @favorites_group_name)
    Api.remove_listing group.id, listing_id

    push socket, "unfavorite_listing_success", %{listing_id: listing_id}
    {:noreply, socket}
  end

  def handle_in("viewed_listing", %{"url" => url}, socket) do
    case Channels.get_user_id(socket) do
      {:ok, user_id} ->
        Activity.viewed_listing(user_id, url)
        push socket, "saved_user_viewed_listing", %{url: url}
      {:error, _} ->
        push socket, "failed_saving_viewed_listing", %{url: url}
    end

    {:noreply, socket}
  end
end
