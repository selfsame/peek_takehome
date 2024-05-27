defmodule PeekTakehome.Payment do
  use Ecto.Schema
  import Ecto.Query

  schema "payments" do
    field(:amount_pence, :integer)
    belongs_to(:order, PeekTakehome.Order)
    timestamps()
  end
end
