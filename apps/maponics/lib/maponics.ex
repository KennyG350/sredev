defmodule Maponics do
  @moduledoc """
  Functions for handling Maponics
  """
  import Ecto.Query

  alias Poison.Parser
  alias Maponics.Geosearch
  alias Schema.Repo

  @spec search_by_location(String.t) :: list(Geosearch.t)
  def search_by_location(location) do
    location
    |> Kernel.<>("%")
    |> String.downcase
    |> search_by_location_query
    |> Repo.all
  end

  @spec get_geojson(Geosearch.t) :: %{"coordinates": nonempty_list(any()), "type": String.t}
  def get_geojson(%Geosearch{id: id, type: "cities"}) do
    id
    |> geojson_query(0.001)
    |> Repo.one
    |> Parser.parse
  end

  @spec get_geojson(Geosearch.t) :: %{"coordinates": nonempty_list(any()), "type": String.t}
  def get_geojson(%Geosearch{id: id}) do
    id
    |> geojson_query(0.0001)
    |> Repo.one
    |> Parser.parse
  end

  @spec get_geojson(String.t) :: %{"coordinates": nonempty_list(any()), "type": String.t}
  def get_geojson(id) do
    Geosearch
    |> Repo.get(id)
    |> get_geojson
  end

  @spec search_by_location_query(String.t) :: Ecto.Query.t
  defp search_by_location_query(location) do
    from g in Geosearch,
      where: like(g.searchable_text, ^location)
  end

  @spec geojson_query(String.t, float()) :: Ecto.Query.t
  def geojson_query(id, simplication \\ 0.0001) do
    from(g in "geosearch",
      select: fragment(
      """
      ST_AsGeoJSON(
        ST_Simplify(
          geom,
          round(GREATEST((st_area(geom)/1000)::numeric, ?), 5)
        )
      )
      """,
      ^simplication
      ),
      where: g.id == ^id
    )
  end

end
