defmodule Feeds.Cache do
  use GenServer

  require Ecto.Query

  alias Sre.Location.ViewHelper
  alias Schema.Resource.Feed
  alias Schema.Repo
  alias Ecto.Query

  @server_name :feeds_cache
  @refresh_interval 15 * 60 * 1000 # Update cache every 15 minutes

  @doc """
  init/1

  Initializes the GenServer by scheduling the next cache refresh
  """
  def init(_state) do
    schedule_refresh()
    {:ok, []}
  end

  @doc """
  start_link/0 worker callback function to initialize and periodically refresh cache state

  Also is called by supervisor if the Agent process were to die, and reseeds initial state
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: @server_name)
  end

  @doc """
  get/0

  gets all the feeds from the cache.
  """
  def get do
    GenServer.call(@server_name, :get_feeds)
  end

  @doc """
  handle_info/2

  handles :load_feeds messages by updating the feeds
  and scheduling the next refresh
  """
  def handle_info(:load_feeds, _state) do
    schedule_refresh()
    {:noreply, get_feeds()}
  end

  @doc """
  handle_call/3

  handles :get_feeds messages by returning the feeds
  """
  def handle_call(:get_feeds, _from, state) do
    updated_state = fetch_feeds_if_empty(state)
    {:reply, updated_state, updated_state}
  end

  defp fetch_feeds_if_empty([]) do get_feeds() end
  defp fetch_feeds_if_empty(state) do state end

  defp schedule_refresh do
    Process.send_after(self(), :load_feeds, @refresh_interval)
  end

  defp get_feeds do
    feeds =
      Feed
      |> Query.where([f], f.is_syndicating == true)
      |> Query.where([f], not(is_nil(f.lat)))
      |> Query.where([f], not(is_nil(f.lng)))
      |> Query.where([f], not(is_nil(f.city)))
      |> Query.where([f], not(is_nil(f.state)))
      |> Repo.all

    [
      feeds: feeds,
      feeds_json: feeds_json(feeds)
    ]
  end

  defp feeds_json(feeds) when is_list(feeds) do
    feeds
    |> Enum.map(&feed_to_map/1)
    |> Poison.encode!
  end

  defp feed_to_map(%Feed{} = feed) do
    %{
      "bounds" => ViewHelper.feed_search_bounding_box(feed),
      "latLng" => %{
        "lat" => Decimal.to_float(feed.lat),
        "lng" => Decimal.to_float(feed.lng)
      },
      "city" => feed.city,
      "state" => feed.state
    }
  end
end
