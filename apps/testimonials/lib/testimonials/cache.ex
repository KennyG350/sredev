defmodule Testimonials.Cache do
  @moduledoc """
  Testimonials.Cache is a cache of all (non-deleted) testimonials
  """
  use GenServer
  require Ecto.Query

  alias Testimonials.Repo

  @server_name :testimonial_cache
  @refresh_interval 5 * 60 * 1000 # Update cache every 5 minutes

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
  def start_link(name \\ @server_name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @doc """
  get/0

  gets all the testimonials from the cache.
  """
  def get(name \\ @server_name) do
    GenServer.call(name, :get_testimonials)
  end

  @doc """
  handle_info/2

  handles :load_testimonials messages by updating the testimonials
  and scheduling the next refresh
  """
  def handle_info(:load_testimonials, _state) do
    schedule_refresh()
    {:noreply, get_testimonials()}
  end

  @doc """
  handle_call/3

  handles :get_testimonials messages by returning the testimonials
  """
  def handle_call(:get_testimonials, _from, state) do
    updated_state = fetch_testimonials_if_empty(state)
    {:reply, updated_state, updated_state}
  end

  defp fetch_testimonials_if_empty([]) do get_testimonials() end
  defp fetch_testimonials_if_empty(state) do state end

  defp schedule_refresh do
    Process.send_after(self(), :load_testimonials, @refresh_interval)
  end

  defp get_testimonials do
    Testimonials.Testimonial
    |> Repo.all
  end

end
