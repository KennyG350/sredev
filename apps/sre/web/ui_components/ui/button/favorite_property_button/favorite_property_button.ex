defmodule Sre.UI.Button.FavoritePropertyButton do
  use Sre.Web, :ui_component

  @defaults []
  @favorites_group_name "Favorites"

  alias Schema.Resource.Listing

  def render_template(opts \\ []) do
    render "favorite_property_button.html", Keyword.merge(@defaults, opts)
  end

  def favorited?(%Listing{groups: []}), do: false
  def favorited?(%Listing{groups: groups} = listing) when is_list(groups) do
    listing.groups
    |> Enum.any?(fn g -> g.name == @favorites_group_name end)
  end
  def favorited?(_) do
    false
  end

  def elm_classes(listing) do
    "elm-favorite-listing-button elm-favorite-listing-button-" <> Integer.to_string(listing.id)
  end
end
