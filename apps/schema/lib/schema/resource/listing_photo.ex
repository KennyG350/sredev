defmodule Schema.Resource.ListingPhoto do
  @moduledoc """
  Listing Photo Model
  """

  use Ecto.Schema

  @derive {Poison.Encoder, only: [:position, :description, :path]}

  schema "listing_photos" do
    belongs_to :listing, Schema.Resource.Listing
    field :position, :integer
    field :description, :string
    field :path, :string
  end

end
