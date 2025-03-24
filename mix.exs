defmodule BambooCustomerIO.Mixfile do
  use Mix.Project

  @version "0.0.3"
  @source_url "https://github.com/jtsmills/bamboo_customerio"

  def project do
    [
      app: :bamboo_customerio,
      version: @version,
      elixir: "~> 1.14",
      source_url: @source_url,
      homepage_url: @source_url,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "customer.io Bamboo Adapter",
      description: "A customer.io adapter for Bamboo",
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["jtsmills"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:bamboo, "~> 2.4"},
      {:cowboy, "~> 2.6", only: [:test, :dev]},
      {:plug_cowboy, "~> 2.0", only: [:test, :dev]},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end
end
