defmodule HealthWebWeb.Router do
  use HealthWebWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthWebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HealthWebWeb do
    pipe_through :browser

    live_session :default, on_mount: [{HealthWebWeb.AssignStaticData, :fetch_static_data}, {HealthWebWeb.AssignRecentPost, :fetch_recent_diseases}] do
      live("/", HomeLive, :index)
      live("/category", CategoryLive, :index)
      live("/category/:params", CategoryLive, :index)
    end
  end

  pipeline :detail do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthWebWeb.Layouts, :detail}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", HealthWebWeb do
    pipe_through :detail
    live_session :detail, on_mount: [{HealthWebWeb.AssignStaticData, :fetch_static_data}, {HealthWebWeb.AssignRecentPost, :fetch_recent_diseases}] do
      live("/health-consultation", ConsultationDetailsLive, :index)
      live("/health-consultation/:params_id", ConsultationDetailsLive, :index)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", HealthWebWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:health_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HealthWebWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
