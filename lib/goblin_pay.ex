defmodule GoblinPay do
  def capture_payment(_attrs) do
    # Fail about 25% of the time
    [:success, :success, :success, :failure] |> Enum.random()
  end
end
