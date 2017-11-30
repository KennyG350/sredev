defmodule Sre.PropertyView do
  use Sre.Web, :view

  def render("search.json", %{data: %{records: records, total: total}}) do
    %{total: total,
      records: records
     }
  end

  def render("show.json", %{data: listing}), do: listing
end
