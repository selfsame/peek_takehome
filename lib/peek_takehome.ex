defmodule PeekTakehome do
  import Ecto.Query
  @moduledoc """
  Documentation for `PeekTakehome`.
  """

  @doc """

  """
  def create_order(email, value, idempotency \\ nil) do
    PeekTakehome.Order.changeset(%PeekTakehome.Order{}, %{
      email: email,
      value_pence: value,
      due_pence: value})
    |> PeekTakehome.Repo.insert
  end

  def get_order(order_id) do
    PeekTakehome.Order
    |> preload(:payments)
    |> PeekTakehome.Repo.get(order_id)
  end

  def get_orders_for_customer(email) do
    PeekTakehome.Order
    |> where([x], x.email == ^email)
    |> where([x], x.valid)
    |> preload(:payments)
    |> PeekTakehome.Repo.all
  end

  def apply_payment_to_order(order_id, value, idempotency \\ nil) do

  end

  def create_order_and_pay(email, value, idempotency \\ nil) do

  end


end
