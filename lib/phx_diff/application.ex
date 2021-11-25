defmodule PhxDiff.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: PhxDiff.PubSub},
      # Start the endpoint when the application starts
      PhxDiffWeb.Endpoint
      # Start a worker by calling: PhxDiff.Worker.start_link(arg)
      # {PhxDiff.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxDiff.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxDiffWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
