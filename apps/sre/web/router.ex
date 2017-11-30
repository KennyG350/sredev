defmodule Sre.Router do
  use Sre.Web, :router
  use Plug.ErrorHandler
  use Phoenix.Router

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  alias Plug.Conn

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    conn_data = conn
      |> Conn.fetch_cookies()
      |> Conn.fetch_query_params()
      |> Conn.fetch_session()

    conn_data = %{
      "request" => %{
        "cookies" => conn_data.req_cookies,
        "url" => "#{conn_data.scheme}://#{conn_data.host}:#{conn_data.port}#{conn_data.request_path}",
        "user_ip" => (conn_data.remote_ip |> Tuple.to_list() |> Enum.join(".")),
        "headers" => Enum.into(conn_data.req_headers, %{}),
        "session" => conn_data.private[:plug_session] || %{},
        "params" => conn_data.params,
        "method" => conn_data.method
      },
      "server" => %{
        "pid" => System.get_env("MY_SERVER_PID"),
        "host" => "#{System.get_env("MY_HOSTNAME")}:#{System.get_env("MY_PORT")}",
        "root" => System.get_env("MY_APPLICATION_PATH")
      }
    }

    Rollbax.report(kind, reason, stacktrace, %{}, conn_data)
  end

  pipeline :browser do
    plug Sre.Plugs.EnforceDomain
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug PlugForwardedPeer
    plug User.Auth
    plug Sre.UserIp
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :ui_guide_layout do
    plug :put_layout, {Sre.LayoutView, :ui_guide}
  end

  pipeline :non_prod do
    plug Sre.Plugs.EnvironmentWhitelist, [:dev, :qa]
  end

  scope "/", Sre do
    pipe_through [:browser]

    get "/",        PageController, :index
    get "/terms",   PageController, :terms
    get "/privacy", PageController, :privacy
    get "/about",   PageController, :about
    get "/solution",   PageController, :solution
    get "/homebuyer",   PageController, :solution
    get "/contact", PageController, :contact
    get "/sell",    PageController, :selling
    get "/careers",    PageController, :careers
    get "/agency",  PageController, :agency
    get "/savings", PageController, :savings
    get "/testimonials", PageController, :testimonials
    get "/home-mortgage-rate-calculator", PageController, :home_mortgage_rate_calculator
    get "/mortgage", PageController, :mortgage
    get "/platform", PageController, :platform
    get "/partners", PageController, :partners
    get "/rewards", PageController, :careers
    post "/rewards", PageController, :send_rewards_message

    # Property pages
    get "/properties", PropertyController, :index
    get "/properties/:url", PropertyController, :details

    get  "/update_password", UserManagement.PasswordController, :reset_password
    post "/update_password", UserManagement.PasswordController, :request_reset

    get  "/change_password", UserManagement.PasswordController, :edit
    put  "/change_password", UserManagement.PasswordController, :update

    get "/verify_account/:token", Registration, :verify

    get "/invite", SessionController, :invite
    get "/login",  SessionController, :new
    get "/logout", AuthController, :delete
    get "/sitemap.xml", PageController, :sitemap

    get "/500", PageController, :error_500
    get "/404", PageController, :error_404
  end

  scope "/api/v1", Sre do
    pipe_through :api

    scope "/listings" do
      pipe_through [:non_prod]
      get "/", PropertyApiController, :index
      get "/:id", PropertyApiController, :show
    end

    scope "/users" do
      pipe_through :api
    end
  end

  scope "/mysre", Sre.UserManagement, as: :user_management do
    pipe_through :browser
    get "/", PageController, :index
    get "/favorites", GroupController, :index
    get "/edit-profile", UserController, :edit
    put "/edit-profile/:user_id", UserController, :update
    put "/edit-profile/:user_id/change_password", PasswordController, :update
    get "/edit-profile/:user_id/email/edit", EmailController, :edit
    put "/edit-profile/:user_id/email", EmailController, :update
    get "/saved-search", SavedSearchController, :index
    delete "/saved-search/:id", SavedSearchController, :delete
    get "/verify-email/:user_id/email", EmailController, :verify
    post "/change_password", PasswordController, :auth_0_update

    get "/agent-suggestions", SuggestionController, :index
  end

  scope "/auth", Sre do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/ui-kit", Sre do
    pipe_through [:non_prod, :browser, :csrf, :ui_guide_layout]
    get "/", UIStyleGuideController, :index
    get "/colors", UIStyleGuideController, :colors
    get "/typography", UIStyleGuideController, :typography
    get "/icons", UIStyleGuideController, :icons
    get "/buttons", UIStyleGuideController, :buttons
    get "/form-elements", UIStyleGuideController, :form_elements
    get "/content-types", UIStyleGuideController, :content_types
    get "/notification", UIStyleGuideController, :notification
    get "/location-components", UIStyleGuideController, :location_components
  end

end
