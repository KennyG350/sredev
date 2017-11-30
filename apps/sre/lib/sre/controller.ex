defmodule Sre.Controller do
  @moduledoc """
  Customizations for Phoenix Controllers for example: modifying the standard
  action plug to pass in the current_user.

    use Sre.Controller

    def show(conn, _params, current_user) do
      #...
    end

  """

  defmacro __using__(_) do
    quote do
      def action(conn, _), do: Sre.Controller.__action__(__MODULE__, conn)
      defoverridable action: 2
    end
  end

  @doc """
  controller - when the AST is generated with
  `use Sre.Controller` controller gets interpreted as the parent calling module.
  """
  def __action__(controller, conn) do
    args = [conn, conn.params, conn.assigns[:current_user]]
    apply(controller, Phoenix.Controller.action_name(conn), args)
  end

end
