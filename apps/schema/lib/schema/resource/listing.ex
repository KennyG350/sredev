defmodule Schema.Resource.Listing do
  @moduledoc """
  Listing Model
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Schema.Resource.{
    Group,
    Lead
  }

  schema "listings" do
    has_many :photos, Schema.Resource.ListingPhoto
    belongs_to :feed, Schema.Resource.Feed
    many_to_many :groups, Group, join_through: "groups_listings"
    has_many :leads, Lead

    field :rets_id, :string
    field :street_number, :string
    field :street_name, :string
    field :street_dir_prefix, :string
    field :street_dir_suffix, :string
    field :street_suffix, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    field :bedrooms, :decimal
    field :baths, :decimal
    field :half_baths, :decimal
    field :type, :string
    field :square_footage, :decimal
    field :latitude, :decimal, precision: 8, scale: 6
    field :longitude, :decimal, precision: 8, scale: 6
    field :price, :decimal
    field :last_modified, Timex.Ecto.DateTime
    field :flooring, :string
    field :inclusions, :string
    field :mls_office_name, :string
    field :lot_features, :string
    field :community_features, :string
    field :mls, :string
    field :mls_listing_id, :string
    field :mls_agent_full_name, :string
    field :model, :string
    field :units_in_building, :string
    field :original_entry_timestamp, Timex.Ecto.DateTime
    field :parcel_number, :string
    field :parking_features, :string
    field :pool_features, :string
    field :public_remarks, :string
    field :roof, :string
    field :living_area, :decimal
    field :exterior_square_footage, :decimal
    field :status, :string
    field :tax_amount, :decimal
    field :tax_assessed_value, :decimal
    field :assessment_improvement_value, :decimal
    field :tax_year, :string
    field :unit_features, :string
    field :unit_number, :string
    field :utilities, :string
    field :view, :string
    field :year_built, :decimal
    field :association_name, :string
    field :association_fee, :decimal
    field :association_fee_2, :decimal
    field :association_fee_2_includes, :string
    field :association_fee_includes, :string
    field :association_fee_total, :decimal
    field :url, :string
    field :virtual_tour, :string
    field :garage_spaces, :decimal
    field :has_association, :boolean
    field :association_fee_frequency, :string
    field :association_fee_2_frequency, :string
    field :raw_status, :string
    field :heating, :string
    field :cooling, :string
    field :subtype, :string
    field :architectural_style, :string
    field :construction_materials, :string
    field :parking_additional, :string
    field :stories, :string
    field :are_pets_allowed, :string
    field :restrictions, :string
    field :is_valid, :boolean
    field :laundry, :string

    field :gas, :string
    field :basement, :string
    field :sewer, :string
    field :fireplaces, :decimal
    field :fireplace_features, :string
    field :foundation_details, :string
    field :amenities, :string

  end

  def changeset(listing, params \\ %{}),
    do: listing |> cast(params, [])

end
