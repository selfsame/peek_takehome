defmodule PeekTakehome do
  import Ecto.Query

  @moduledoc """
  Documentation for `PeekTakehome`.
  """

  @doc """

  """
  def create_order(email, value) do
    PeekTakehome.Order.changeset(%PeekTakehome.Order{}, %{
      email: email,
      value_pence: value,
      due_pence: value
    })
    |> PeekTakehome.Repo.insert()
  end

  def create_order(email, value, idempotency) do
    case Cachex.get(:idempotency, idempotency) do
      {:ok, nil} ->
        result = create_order(email, value)
        Cachex.put(:idempotency, idempotency, result)
        result
      {:ok, result} -> result
    end
  end

  def get_order(order_id) do
    PeekTakehome.Order
    |> preload(:payments)
    |> PeekTakehome.Repo.get(order_id)
    |> case do
      nil -> {:error, "No order found for id #{order_id}"}
      order -> {:ok, order}
    end
  end

  def get_orders_for_customer(email) do
    PeekTakehome.Order
    |> where([x], x.email == ^email)
    |> where([x], x.valid)
    |> preload(:payments)
    |> PeekTakehome.Repo.all()
  end


  def apply_payment_to_order(order_id, amount_pence, idempotency \\ nil) do
    with {_, {:ok, order}} <- {:order, get_order(order_id)},
         {_, true} <- {:order_validity, order.valid},
         {_, true} <- {:value_assert, order.due_pence - amount_pence >= 0},
         {_, :success} <- {:goblin, GoblinPay.capture_payment(order.email)},
         {_, {:ok, payment}} <-
           {:payment, %PeekTakehome.Payment{order_id: order.id, amount_pence: amount_pence} |> PeekTakehome.Repo.insert},
         {_, {:ok, order}} <-
           {:update,
            PeekTakehome.Order.changeset(order, %{due_pence: order.due_pence - amount_pence})
            |> PeekTakehome.Repo.update()} do
      # return the order with the new payment loaded
      get_order(order_id)
    else
      {:order_validity, _} -> {:error, "Order #{order_id} has been marked invalid"}
      {:value_assert, _} -> {:error, "The payment amount is more than the amount due"}
      {:goblin, _} -> {:error, "Goblin Pay was unable to process the payment"}
      err -> {:error, "There was an error processing the payment #{err}"}
    end
  end


  def create_order_and_pay(email, amount_pence, idempotency \\ nil) do
    case create_order(email, amount_pence) do
      {:ok, order} ->
        case apply_payment_to_order(order.id, amount_pence, idempotency) do
          {:ok, paid_order} -> {:ok, paid_order}
          err ->
            PeekTakehome.Order.changeset(order, %{valid: false})
            |> PeekTakehome.Repo.update()
            err
        end
      err -> err
    end
  end

end
