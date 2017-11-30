defmodule Schema.Resource.Feed do
  @moduledoc """
  Feed Model
  """

  use Ecto.Schema

  @derive {Poison.Encoder, only: [:id, :is_syndicating, :feed_connection]}

  schema "feeds" do
    has_many :listing, Schema.Resource.Listing
    belongs_to :feed_connection, Schema.Resource.FeedConnection

    field :is_syndicating, :boolean
    field :lat, :decimal, precision: 8, scale: 6
    field :lng, :decimal, precision: 8, scale: 6
    field :city, :string
    field :state, :string
  end

end
