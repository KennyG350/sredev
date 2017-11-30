defmodule Sre.UserManagement.SavedSearchView do
  use Sre.Web, :view

  def encode_search_attributes(attrs) do
    attrs
    |> attributes_to_map
    |> attributes_map_to_query_params
  end

  def attributes_to_map([]), do: %{}
  def attributes_to_map(attrs) do
    attrs
    |> Enum.reduce(%{}, fn(%{attribute_key: key, attribute_values: value}, acc) ->
        acc
        |> Map.put(key, value)
       end)
  end

  def attributes_map_to_query_params(map) when map == %{}, do: ""
  def attributes_map_to_query_params(attrs_map) do
    attrs_map
    |> URI.encode_query
  end
end
