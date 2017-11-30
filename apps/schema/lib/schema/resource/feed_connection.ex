defmodule Schema.Resource.FeedConnection do
  @moduledoc """
  Feed Connection Model
  """

  use Ecto.Schema

  @derive {Poison.Encoder, only: [:legal_name, :legal_disclaimer, :logo_path]}

  schema "feed_connections" do
    has_many :feeds, Schema.Resource.Feed
    has_many :listings, Schema.Resource.Listing

    has_many :feeds_listings, through: [:feeds, :listings]

    field :legal_name, :string
    field :rebate_amount, :decimal
    field :co_branding, :boolean
    field :legal_disclaimer, :string
    field :logo_path, :string

  end

end
