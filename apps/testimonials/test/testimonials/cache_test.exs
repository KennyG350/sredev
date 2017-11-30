defmodule Testimonials.CacheTest do
  use ExUnit.Case, async: true

  alias Testimonials.Cache

  setup do
    {:ok, cache_pid: GenServer.whereis :testimonial_cache}
  end

  test "application should start and starts a new testimonial cache", %{cache_pid: pid} do
    assert Process.alive? pid
  end

  test "start_link/1 on start reads database and caches all testimonals" do
    state = Cache.get

    assert Enum.all?(state, &testimonial?/1)
  end

  test "get/1 returns the cache state which wll be a list" do
    state = Cache.get
    assert is_list(state)
  end

  test "gets restarted if dies", %{cache_pid: pid} do
    ## Stop the main cache that begins with application starts
    Process.exit pid, :shutdown

    # sleep to give the VM time to shut down and restart the process
    :timer.sleep 1000

    ## Supervisor should restart automatcially, reseeding cache
    ## so we should be able to get the Testimonials from it
    state = Cache.get
    assert is_list(state) && Enum.all?(state, &testimonial?/1)
  end

  defp testimonial?(%Testimonials.Testimonial{}), do: true
  defp testimonial?(_), do: false
end
