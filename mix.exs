defmodule Agala.Provider.Viber.MixProject do
  use Mix.Project

  def project do
    [
      app: :agala_viber,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:agala, github: "IT-CTI/agala", branch: "2.5"},
      {:jason, "~> 1.1"},
      {:plug, "~> 1.6"},
      {:httpoison, "~> 1.2"},
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end
end
