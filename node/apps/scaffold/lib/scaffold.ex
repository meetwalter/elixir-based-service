defmodule Scaffold do
  @moduledoc ~S"""
  """

  require Logger

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Scaffold.Server, []),
    ]

    opts = [
      name: Scaffold.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end
end
