defmodule Sre.UI.Button.SocialButton do
  use Sre.Web, :ui_component

  @defaults [network: "facebook", classname: ""]

  def render_template(opts \\ []) do
    render "social_button.html", Keyword.merge(@defaults, opts)
  end

end
