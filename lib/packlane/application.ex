defmodule Packlane.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Packlane.Repo,
      # Start the Telemetry supervisor
      PacklaneWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Packlane.PubSub},
      # Start the Endpoint (http/https)
      PacklaneWeb.Endpoint
      # Start a worker by calling: Packlane.Worker.start_link(arg)
      # {Packlane.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Packlane.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PacklaneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
