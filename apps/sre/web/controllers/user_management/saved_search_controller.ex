defmodule Sre.UserManagement.SavedSearchController do
  use Sre.Web, :controller

  alias User.Search
  alias Poison.Parser

  def index(conn, _params) do
    searches =
      conn.assigns.current_user.id
      |> Search.get_searches_by_user_id
      |> Enum.map(fn(%{search_attributes: attrs} = search) ->
          attrs =
            attrs
            |> Enum.map(&decode_values/1)

          %{search | search_attributes: attrs}
         end)
    conn
    |> render("index.html", searches: searches)
  end

  def delete(conn, %{"id" => saved_search_id}) do
    conn.assigns.current_user.id
    |> Search.delete_search(saved_search_id)

    conn
    |> redirect(to: user_management_saved_search_path(conn, :index))
  end

  def decode_values(%{attribute_key: key, attribute_values: value} = attrs) do
    key = parse(key)
    value = parse(value)

    %{attrs | attribute_key: key, attribute_values: value}
  end

  defp parse(value) do
    case Parser.parse value do
      {:ok, result} -> result
      {:error, _} -> ""
    end
  end

end
