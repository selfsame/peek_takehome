defmodule PeekTakehome do
  import Ecto.Query

  def create_order(email, value_pence) do
    PeekTakehome.Order.changeset(%PeekTakehome.Order{}, %{
      email: email,
      value_pence: value_pence,
      due_pence: value_pence
    })
    |> PeekTakehome.Repo.insert()
  end

  def create_order(email, value_pence, idempotency) do
    case Cachex.get(:idempotency, idempotency) do
      {:ok, nil} ->
        result = create_order(email, value_pence)
        Cachex.put(:idempotency, idempotency, result)
        result

      {:ok, result} ->
        result
    end
  end

  def get_order(order_id) do
    PeekTakehome.Order
    |> preload(:payments)
    |> PeekTakehome.Repo.get(order_id)
    |> case do
      nil -> {:error, "No order found for id #{order_id}"}
      %PeekTakehome.Order{valid: false} -> {:error, "Order #{order_id} is not valid"}
      order -> {:ok, order}
    end
  end

  def get_orders_for_customer(email) do
    res =
      PeekTakehome.Order
      |> where([x], x.email == ^email)
      |> where([x], x.valid)
      |> preload(:payments)
      |> PeekTakehome.Repo.all()

    {:ok, res}
  end

  def apply_payment_to_order(order_id, amount_pence) do
    with {_, {:ok, order}} <- {:order, get_order(order_id)},
         {_, true} <- {:order_validity, order.valid},
         {_, true} <- {:value_assert, order.due_pence - amount_pence >= 0},
         {_, :success} <- {:goblin, GoblinPay.capture_payment(order.email)},
         {_, {:ok, payment}} <-
           {:payment,
            %PeekTakehome.Payment{order_id: order.id, amount_pence: amount_pence}
            |> PeekTakehome.Repo.insert()},
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
      {_, err} -> {:error, "There was an error processing the payment: #{err}"}
    end
  end

  def apply_payment_to_order(order_id, amount_pence, idempotency) do
    case Cachex.get(:idempotency, idempotency) do
      {:ok, nil} ->
        result = apply_payment_to_order(order_id, amount_pence)
        Cachex.put(:idempotency, idempotency, result)
        result

      {:ok, result} ->
        result
    end
  end

  # It is assumed we are paying off the entire order in this payment.
  # The order is created even if the payment fails, but we mark it as invalid
  def create_order_and_pay(email, amount_pence) do
    case create_order(email, amount_pence) do
      {:ok, order} ->
        case apply_payment_to_order(order.id, amount_pence) do
          {:ok, paid_order} ->
            {:ok, paid_order}

          err ->
            PeekTakehome.Order.changeset(order, %{valid: false})
            |> PeekTakehome.Repo.update()

            err
        end

      err ->
        err
    end
  end

  def create_order_and_pay(email, amount_pence, idempotency) do
    case Cachex.get(:idempotency, idempotency) do
      {:ok, nil} ->
        result = create_order_and_pay(email, amount_pence)
        Cachex.put(:idempotency, idempotency, result)
        result

      {:ok, result} ->
        result
    end
  end
end
