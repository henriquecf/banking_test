defmodule PacklaneWeb.Router do
  use PacklaneWeb, :router
  use Kaffy.Routes #, scope: "/admin", pipe_through: [:some_plug, :authenticate]

  import PacklaneWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PacklaneWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_current_user
  end

  scope "/", PacklaneWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", AccountLive.Index, :index

    live "/banking_accounts", AccountLive.Index, :index
    live "/banking_accounts/new", AccountLive.Index, :new
    live "/banking_accounts/new_transaction", AccountLive.Index, :new_transaction
    live "/banking_accounts/:id/edit", AccountLive.Index, :edit

    live "/banking_accounts/:id", AccountLive.Show, :show
    live "/banking_accounts/:id/show/edit", AccountLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  scope "/api", PacklaneWeb do
    pipe_through [:api, :require_authenticated_user]

    resources "/banking_accounts", AccountController, except: [:new, :edit, :update]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PacklaneWeb.Telemetry, ecto_repos: [Packlane.Repo]
    end
  end

  ## Authentication routes

  scope "/", PacklaneWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :put_session_layout]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", PacklaneWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", PacklaneWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
