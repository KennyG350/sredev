defmodule Sre.UIStyleGuideController do
  use Sre.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def colors(conn, _params) do
    render conn, "colors.html"
  end

  def typography(conn, _params) do
    render conn, "typography.html"
  end

  def icons(conn, _params) do
    render conn, "icons.html"
  end

  def buttons(conn, _params) do
    render conn, "buttons.html"
  end

  def form_elements(conn, _params) do
    render conn, "form_elements.html"
  end

  def content_types(conn, _params) do
    render conn, "content_types.html"
  end

  def notification(conn, _params) do
    render conn, "notification.html"
  end

  def location_components(conn, _params) do
    render conn, "location_components.html"
  end
end
