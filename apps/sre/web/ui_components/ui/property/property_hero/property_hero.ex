defmodule Sre.UI.Property.PropertyHero do
  use Sre.Web, :ui_component

  alias Schema.Resource.Listing

  @defaults []

  @photo_manipulation "?fit=fill&h=960&w=1440&bg=20242b&or=0"

  @placeholder_photo "website-photos/property-hero--placeholder.jpg"

  def render_template(opts \\ []) do
    render "property_hero.html", Keyword.merge(@defaults, opts)
  end

  def get_first_photo(listing) do
    listing.photos
    |> Enum.sort_by(&(&1.position))
    |> Enum.at(0)
    |> append_to_photo_path
  end

  def get_all_photo_paths(%Listing{photos: []}), do: [append_to_photo_path []]
  def get_all_photo_paths(listing) do
    listing.photos
    |> Enum.sort_by(&(&1.position))
    |> Enum.map(&append_to_photo_path/1)
  end

  defp append_to_photo_path(nil) do
    [Application.get_env(:sre, :photo_cdn), @placeholder_photo, @photo_manipulation]
    |> Enum.join("")
  end
  defp append_to_photo_path([]) do
    [Application.get_env(:sre, :photo_cdn), @placeholder_photo, @photo_manipulation]
    |> Enum.join("")
  end
  defp append_to_photo_path(photo) do
    [Application.get_env(:sre, :photo_cdn), photo.path, @photo_manipulation]
    |> Enum.join("")
  end

end
