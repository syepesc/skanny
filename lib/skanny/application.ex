defmodule Skanny.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkannyWeb.Telemetry,
      Skanny.Repo,
      {DNSCluster, query: Application.get_env(:skanny, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Skanny.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Skanny.Finch},
      # Start a worker by calling: Skanny.Worker.start_link(arg)
      # {Skanny.Worker, arg},
      # Start to serve requests, typically the last entry
      SkannyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Skanny.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkannyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
