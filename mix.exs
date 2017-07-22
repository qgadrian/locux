defmodule Locux.Mixfile do
  use Mix.Project

  def project do
    [
      app: :locux,
      version: "0.0.1",
      elixir: "~> 1.4.5",
      escript: [main_module: Locux],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
     ]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.12"},
      {:progress_bar, "> 0.0.0"},
      {:statistics, "~> 0.4.1"},
      {:credo, "~> 0.8.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "build": ["compile", "escript.build"]
    ]
  end
end
