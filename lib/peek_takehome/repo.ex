defmodule PeekTakehome.Repo do
  use Ecto.Repo,
    otp_app: :peek_takehome,
    adapter: Ecto.Adapters.SQLite3
end
