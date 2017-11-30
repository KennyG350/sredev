defmodule Schema.Resource.Search do
  @moduledoc """
  Schema for a search
  """
  import Ecto.Changeset
  use Ecto.Schema

  alias Schema.Resource.{
    User,
    SearchAttribute
  }

  schema "searches" do
    has_many :search_attributes, SearchAttribute, on_delete: :delete_all
    belongs_to :user, User
    field :name, :string
    field :anonymous_id, :integer
    field :saved, :boolean
    field :created_by, :integer
    field :hash, :string

    timestamps inserted_at: :created_at, updated_at: false
  end

  @allowed [:name, :anonymous_id, :saved, :created_by, :hash]

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @allowed)
    |> cast_assoc(:user)
    |> cast_assoc(:search_attributes)
  end

end
