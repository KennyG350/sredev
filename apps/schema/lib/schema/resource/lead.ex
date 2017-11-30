defmodule Schema.Resource.Lead do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schema.{
    Resource.Listing,
    Resource.User
  }

  schema "leads" do
    belongs_to :listing, Listing
    many_to_many :users, User, join_through: "leads_users"

    field :status, :string
    field :lead_type, :string
  end

  def changeset(lead, params \\ %{}) do
    lead
    |> cast(params, [:status, :lead_type])
    |> cast_assoc(:listing)
    |> cast_assoc(:users)
  end
end
