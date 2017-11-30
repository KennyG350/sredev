defmodule GreatSchools do
  use Application

  def start(_, _) do
    import Supervisor.Spec, warn: false
    children = []
    opts = [strategy: :one_for_one, name: GreatSchools]
    Supervisor.start_link(children, opts)
  end

end
