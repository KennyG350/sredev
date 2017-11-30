defmodule Sre.UI.Property.List.Pagination do
  use Sre.Web, :ui_component

  @defaults [classname: nil]

  alias Sre.Listing.ViewHelper

  def render_template(opts \\ []) do
    render "pagination.html", Keyword.merge(@defaults, opts)
  end

  def first_page?(page) do
    (page || 1) == 1
  end

  def last_page?(page, per_page, total_results) do
    if page >= Float.ceil(total_results / per_page) do
      true
    else
      false
    end
  end

  def previous_page(page) do
    page - 1
  end

  def next_page(page) do
    page + 1
  end

  def start_range(page, per_page) do
    ViewHelper.format_number (per_page * (page - 1)) + 1
  end

  def end_range(page, per_page, total_results) do
    end_range = (page * per_page)

    if end_range > total_results do
      ViewHelper.format_number total_results
    else
      ViewHelper.format_number end_range
    end
  end
end
