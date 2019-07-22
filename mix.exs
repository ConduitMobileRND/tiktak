defmodule TikTak.MixProject do
  use Mix.Project

  def project do
    [
      app: :tiktak,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TikTak.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:plug, "~> 1.6"},
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13"},
      {:crontab, "1.1.2"},
      {:gen_stage, "~> 0.11"},
      {:httpoison, "~> 1.2"},
      {:distillery, "~> 1.5", runtime: false}
    ]
  end
end
