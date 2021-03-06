defmodule Scaffold.Mixfile do
  use Mix.Project

  @umbrella_apps File.ls!("../../apps")
    |> List.delete("scaffold")
    |> Enum.map(&String.to_atom/1)

  @umbrella_deps @umbrella_apps
    |> Enum.map(fn(app_name) -> {app_name, in_umbrella: true} end)


  def project do
    [app: :scaffold,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: (explicit_deps ++ @umbrella_deps)]
  end

  def application do [
    applications: (explicit_apps ++ @umbrella_apps),
    mod: {Scaffold, []}
  ] end

  defp explicit_apps do [
    :pretty_console,
    :exuvia
  ] end

  defp explicit_deps do [
    {:pretty_console, github: "tsutsu/pretty_console"},
    {:exuvia, github: "meetwalter/exuvia"},
  ] end
end
