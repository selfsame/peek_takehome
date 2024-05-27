defmodule PeekTakehome.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PeekTakehome.Repo,
      {Cachex, name: :idempotency}
    ]

    opts = [strategy: :one_for_one, name: PeekTakehome.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
