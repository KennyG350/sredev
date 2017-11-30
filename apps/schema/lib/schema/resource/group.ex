defmodule Schema.Resource.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schema.Resource.{
    User,
    Listing
  }

  schema "groups" do
    belongs_to :user, User
    belongs_to :created_by_user, User, foreign_key: :created_by
    many_to_many :listings, Listing, join_through: "groups_listings", on_replace: :delete

    field :name, :string
  end

  def changeset(group, params \\ %{}) do
    group
    |> cast(params, [:user, :creatd_by, :listings, :name])
  end
end
