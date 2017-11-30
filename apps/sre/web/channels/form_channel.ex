defmodule Sre.FormChannel do
  use Phoenix.Channel

  alias Sre.Channels
  alias User.{
    Management,
    FormMessage
  }
  alias Group.ListingService, as: GroupService
  alias ListingSearch.Search
  alias Sre.Listing.ViewHelper

  def join("form:" <> _user_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("submit_form", attrs, socket) do
    user = find_or_create_user(socket, attrs)
    handle_submission(user, attrs)

    push socket, "form_submitted", %{}
    {:noreply, socket}
  end

  def handle_in("submit_property_details_form", %{"listing_id" => listing_id} = attrs, socket) do
    user = find_or_create_user(socket, attrs)
    handle_submission(user, attrs, listing_id)

    push socket, "property_details_form_submitted", %{}
    {:noreply, socket}
  end

  defp find_or_create_user(socket, attrs) do
    case get_user(socket, attrs) do
      nil ->
        create_user(attrs)

      user ->
        user
    end
  end

  defp get_user(socket, %{"email" => email}) do
    case Channels.get_user_id socket do
      {:ok, user_id} ->
        User.get_user_by_id user_id

      {:error, _} ->
        case User.get_by_email_and_type(email, :external) do
          nil ->
            User.get_by_email_and_type(email, :internal)

          user ->
            user
        end
    end
  end

  defp create_user(%{
    "first_name" => first_name,
    "last_name" => last_name,
    "email" => email,
    "phone" => phone
  }) do
    Management.create_new_user(:params, %{
      email: email,
      phone: phone,
      first_name: first_name,
      last_name: last_name,
      anonymous_id: Management.generate_anonymous_id
    })
  end

  defp handle_submission(user, attrs, listing_id \\ nil)
  defp handle_submission(nil, _, _), do: nil
  defp handle_submission(
    user,
    %{
      "first_name" => first_name,
      "last_name" => last_name,
      "phone" => phone,
      "message" => message
    },
    listing_id
  ) do
    if listing_id do
      add_to_favorites user.id, listing_id
    end

    create_lead user
    update_user user, phone, %{first_name: first_name, last_name: last_name}
    insert_form_message user, build_message(message, listing_id)
  end

  defp create_lead(%{id: user_id}), do: Leads.save_lead "new", {:buyer, user_id}

  defp add_to_favorites(user_id, listing_id) do
    user_id
    |> GroupService.fetch_by_user_id_and_name("Favorites")
    |> GroupService.add_listing(listing_id)
  end

  defp build_message(message, nil), do: message
  defp build_message(message, listing_id) do
    listing_id
    |> Search.fetch_by_id
    |> ViewHelper.address
    |> (fn(address) -> "For listing at: #{address}, #{message}" end).()
  end

  defp update_user(user, phone, params) do
    user
    |> User.preload([:user_profile, :user_phones])
    |> Management.add_user_phones(phone)
    |> User.changeset(params)
    |> User.update
  end

  defp insert_form_message(user, message) do
    user
    |> FormMessage.message_for_user
    |> FormMessage.add_message(message)
    |> FormMessage.insert_message!
  end
end
