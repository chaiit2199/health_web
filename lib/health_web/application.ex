defmodule HealthWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # topologies = [
    #   example: [
    #     strategy: Cluster.Strategy.Epmd,
    #     config: [hosts: [:"backend_pubsub@10.140.18.235"]],
    #   ]
    # ]
    children = [
      # Start the Telemetry supervisor
      HealthWebWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HealthWeb.PubSub},
      # Start Finch
      {Finch, name: HealthWeb.Finch},
      # Start the Endpoint (http/https)


      # {Cluster.Supervisor, [topologies, [name: HealthWeb.ClusterSupervisor]]},
      # Supervisor.child_spec({Phoenix.PubSub, name: BackendPubsub.PubSub}, id: Trading.InternalPubSub),

      HealthWebWeb.Endpoint
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
