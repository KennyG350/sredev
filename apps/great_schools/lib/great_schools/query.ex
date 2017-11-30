defmodule GreatSchools.Query do

  alias Schema.Repo
  alias Schema.Resource.School

  @doc """
  Example

    GreatSchools.Query.fetch_schools_by_listing_id(Integer.t)

  Returns [
    %Schema.Resource.School{__meta__: #Ecto.Schema.Metadata<:loaded, "schools">,
    id: nil, level: nil,
    point: "{\"type\":\"Point\",\"coordinates\":[-157.8241228,21.2797522]}",
    school_education_level: "Primary",
    school_name: "PRESIDENT THOMAS JEFFERSON ELEMENTARY SCHOOL",
    school_rating: nil}
  ]

  """
  def fetch_schools_by_listing_id(id) do
    select_query =
  """
  SELECT
  schools.school_name,
  schools.school_education_level,
  schools.school_level,
  schools.school_type,
  schools.school_rating,
  ST_DistanceSpheroid(
    schools.school_geom,
    listings.geo,
    'SPHEROID["WGS 84",6378137,298.257223563]'
    )*0.621371/1000 AS distance,
    ST_AsGeoJSON(listings.geo) point
  """
    from_query =
  """
  FROM schools INNER JOIN listings ON ST_Intersects(schools.attendance_zone_geom, listings.geo)
  WHERE listings.id = $1
  ORDER BY
  CASE WHEN substring(school_level FROM 1 FOR 1) = 'P' THEN 0
        WHEN substring(school_level FROM 1 FOR 1) = 'K' THEN 1
        ELSE 2 END ASC,
  school_level ASC NULLS LAST,
  schools.school_rating DESC NULLS LAST,
  distance ASC;
 """
    query = select_query <> from_query
    Repo.execute_and_load(query, [id], School)
  end
end
