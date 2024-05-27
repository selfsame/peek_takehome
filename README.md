# PeekTakehome

This repo implements an internal order taking Module called `PeekTakehome` that persists `Order` and `Payment` models to a sqlite3 database. The function implementations can be seen in [peek_takehome.ex](https://github.com/selfsame/peek_takehome/blob/main/lib/peek_takehome.ex)

### getting set up

* install `elixir`
* `cd peek_takehome`
* `mix deps.get`
* `mix ecto.create`
* `iex -S mix` to run repl

### notes

All functions should return `{:ok, _}` or `{:error, _}` tuples with human readable error strings.

`create_order`, `apply_payment_to_order`, and `create_order_and_pay` take an optional idempotency argument which is assumed to be a uuid. Idempotency is implemented with Cachex with a time to life of 10 minutes.