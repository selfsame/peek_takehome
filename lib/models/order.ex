defmodule PeekTakehome.Order do
  use Ecto.Schema
  import Ecto.Query

  schema "orders" do
    field :email, :string
    field :value_pence, :integer
    field :due_pence, :integer
    field :valid, :boolean, default: true
    has_many(:payments, PeekTakehome.Payment)
    timestamps()
  end
end
