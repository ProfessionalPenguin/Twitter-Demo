defmodule Proj4.MixProject do
  use Mix.Project

  def project do
    [
      app: :proj4,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
     # aliases: [test: "test --no-start"],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [Application.start(Proj4.Proj4),
      extra_applications: [:logger],
      mod: {Proj4.Proj4, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
