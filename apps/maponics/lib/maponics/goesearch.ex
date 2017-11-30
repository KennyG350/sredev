defmodule Maponics.Geosearch do
  use Ecto.Schema

  @opaque t :: %__MODULE__{}

  @primary_key {:id, :string, []}

  schema "geosearch" do
    field :name, :string
    field :type, :string
    field :city, :string
    field :state, :string
    field :searchable_text, :string
  end
end
