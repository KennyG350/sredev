defmodule Sre.LayoutView do
  use Sre.Web, :view

  def tracking_enabled do
    Application.get_env(:sre, :tracking_enabled)
  end

  def allow_indexing do
    Application.get_env(:sre, :allow_indexing)
  end

  def rollbar_tracking do
    Application.get_env(:rollbax, :enabled) !== false
  end

  def get_current_user(nil), do: %{id: false}
  def get_current_user(user), do: user
end
