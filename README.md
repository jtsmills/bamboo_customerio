# Bamboo.CustomerIOAdapter

A [customer.io](https://www.customer.io) adapter for [Bamboo](https://github.com/thoughtbot/bamboo).

## Installation

1. Add `bamboo_customerio` to your dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:bamboo_customerio, "~> 0.0.2"}]
  end
  ```

2. Update your config file (`config/config.exs`) with your API keys.

  ```elixir
  config :my_app, MyApp.Mailer,
    adapter: Bamboo.CustomerIOAdapter,
    api_key: "my_api_key"
  ```