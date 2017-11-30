defmodule ListingSearch.NoResultsError do
  #defexception [:message]

  defexception plug_status: 404, message: "no route found", conn: nil, router: nil

  # opts shoudl contain slug
  def exception(opts) do

    msg = """
    could not find property for slug:
    #{opts[:url]}
    """

    %__MODULE__{message: msg}
  end

  def status(_exception) do
    404
  end
end

defmodule ListingSearch.BadInputError do
  defexception plug_status: 422, message: "no route found", conn: nil, router: nil

  # opts should contain input
  def exception(opts) do

    msg = """
    input not valid:
    #{opts[:input]}
    """

    %__MODULE__{message: msg}
  end

  def status(_exception) do
    404
  end
end
