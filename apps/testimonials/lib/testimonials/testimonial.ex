defmodule Testimonials.Testimonial do
  @moduledoc """
  Testimonal Schema
  """
  use Ecto.Schema

  schema "testimonials" do
    field :endorser, :string
    field :testimonial, :string
    field :amount_received, :integer
    field :location, :string

    timestamps
  end
end
