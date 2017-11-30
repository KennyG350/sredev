defmodule Sre.UI.Property.PropertyAccordion.Schools do
  use Sre.Web, :ui_component

  @defaults [schools: []]

  def render_template(opts \\ []) do
    render "schools.html", Keyword.merge(@defaults, opts)
  end

  def school_type(nil), do: ""

  def school_type(value) do
    String.capitalize(value)
  end

  def school_rating_color rating do
    cond do
      rating >= 8 -> "gs-rating__disc--gs-rating-good"
      rating >= 4 -> "gs-rating__disc--gs-rating-ok"
      rating <= 3 -> "gs-rating__disc--gs-rating-poor"
      true -> "gs-rating__disc--gs-rating-na"
    end
  end
end
