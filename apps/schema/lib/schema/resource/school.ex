defmodule Schema.Resource.School do
  @moduledoc """
  School Schema
  """
  use Ecto.Schema

  schema "schools" do
    field :school_name
    field :school_education_level
    field :school_level
    field :school_type
    field :level
    field :school_rating, :integer
    field :point
  end
end
