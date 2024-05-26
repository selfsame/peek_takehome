defmodule PeekTakehome.Repo.Migrations.PaymentTable do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount_pence, :integer
      add :order_id, references(:orders)
      timestamps()
    end
  end
end
