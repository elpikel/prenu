defmodule Prenu.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PrenuWeb.Telemetry,
      # Start the Ecto repository
      Prenu.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Prenu.PubSub},
      # Start Finch
      {Finch, name: Prenu.Finch},
      # Start the Endpoint (http/https)
      PrenuWeb.Endpoint
      # Start a worker by calling: Prenu.Worker.start_link(arg)
      # {Prenu.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prenu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrenuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
