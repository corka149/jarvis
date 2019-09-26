defmodule Mix.Tasks.Docker do
  use Mix.Task

  @shortdoc "Creates a docker image with tags"
  def run(_opts) do
    version = Jarvis.MixProject.project() |> Keyword.fetch!(:version)

    System.cmd("docker", ["build", "-t", "jarvis:" <> version, "-t", "jarvis:latest", "."],
      into: IO.stream(:stdio, :line)
    )
  end
end
