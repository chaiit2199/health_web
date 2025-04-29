defmodule HealthWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias FacebookPoster

  @impl true
  def start(_type, _args) do
    fbpost_crontab = Application.get_env(:health_web, :FBPOST_CRONTAB) || "0 0 * * *"

    children = [
      # Start the Telemetry supervisor
      HealthWebWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HealthWeb.PubSub},
      # Start Finch
      {Finch, name: HealthWeb.Finch},
      # Start the Endpoint (http/https)

      HealthWebWeb.Endpoint,
      %{
        id: "daily_post_fb",
        start: {SchedEx, :run_every, [FacebookPoster, :post, [], fbpost_crontab]}
      },
      # Start a worker by calling: HealthWeb.Worker.start_link(arg)
      # {HealthWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HealthWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HealthWebWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
