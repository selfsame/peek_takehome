import Config

config :peek_takehome,
  ecto_repos: [PeekTakehome.Repo]

config :peek_takehome, PeekTakehome.Repo,
  database: "database.db"
