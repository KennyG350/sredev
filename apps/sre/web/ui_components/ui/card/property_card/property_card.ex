defmodule Sre.UI.Card.PropertyCard do
  use Sre.Web, :ui_component

  @defaults [image_path: "/images/property.jpg", header?: true, slider?: false]

  @placeholder_photo "website-photos/property-hero--placeholder.jpg"

  alias Schema.Resource.Listing

  def render_template(opts \\ []) do
    render "property_card.html", Keyword.merge(@defaults, opts)
  end

  def get_first_photo(listing) do
    listing.photos
    |> Enum.sort_by(&(&1.position))
    |> Enum.at(0)
    |> append_to_photo_path
  end

  def get_all_photo_paths(%Listing{photos: []}), do: append_to_photo_path []
  def get_all_photo_paths(listing) do
    listing.photos
    |> Enum.sort_by(&(&1.position))
    |> Enum.map(&append_to_photo_path/1)
  end

  defp append_to_photo_path(nil) do
    Application.get_env(:sre, :photo_cdn) <> @placeholder_photo <> "?fit=crop&h=h=400&w=712 "
  end
  defp append_to_photo_path([]) do
    Application.get_env(:sre, :photo_cdn) <> @placeholder_photo <> "?fit=crop&h=h=400&w=712 "
  end
  defp append_to_photo_path(photo) do
    Application.get_env(:sre, :photo_cdn) <> photo.path <> "?fit=crop&h=400&w=712&or=0 "
  end

end
