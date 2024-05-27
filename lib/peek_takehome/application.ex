defmodule PeekTakehome.Application do
  @moduledoc false

  use Application
  import Cachex.Spec

  @impl true
  def start(_type, _args) do
    children = [
      PeekTakehome.Repo,
      {Cachex, name: :idempotency, expiration: expiration(default: 1000 * 60 * 10)}
    ]

    opts = [strategy: :one_for_one, name: PeekTakehome.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
