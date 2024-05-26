defmodule PeekTakehome.Repo.Migrations.OrderTable do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :email, :string
      add :value_pence, :integer
      add :due_pence, :integer
      add :valid, :boolean, default: true
      timestamps()
    end
  end
end
