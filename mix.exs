defmodule DeloresDevJSON.MixProject do
  use Mix.Project

  def project do
    [
      name: "DeloresDevJSON",
      description: description(),
      package: package(),
      app: :deloresdevjson,
      version: "1.0.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:yecc, :leex] ++ Mix.compilers(),
      dialyzer: [],
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/eskil/deloresdev-json",
    ]
  end

  def cli() do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
        "coveralls.html": :test
    ]
  end
  defp description() do
    "A relaxed json compatible with DeloresDev files"
  end

  def application do
    [
      extra_applications: [:logger, :wx]
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/eskil/deloresdev-json"}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
    ]
  end
end
