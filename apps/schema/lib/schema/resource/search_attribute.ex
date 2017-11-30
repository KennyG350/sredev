defmodule Schema.Resource.SearchAttribute do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schema.Resource.Search

  schema "search_attributes" do
    belongs_to :search, Search
    field :attribute_key, :string
    field :attribute_values, :string

    timestamps inserted_at: :created_at, updated_at: false
  end

  @allowed [:attribute_key, :attribute_values]

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @allowed)
    |> cast_assoc(:search)
  end

end
