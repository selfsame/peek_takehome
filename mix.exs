defmodule PeekTakehome.MixProject do
  use Mix.Project

  def project do
    [
      app: :peek_takehome,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PeekTakehome.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sqlite3, "~> 0.13"},
      {:cachex, "~> 3.6"}
    ]
  end
end
