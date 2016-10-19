defmodule Scaffold.Server do
  @moduledoc ~S"""
  """

  use GenServer

  def log(level, str) do
    :global.whereis_name(__MODULE__)
    |> GenServer.call({:log, level, str})
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: {:global, Scaffold.Server})
  end

  def init(state) do
    GenServer.cast(self, :start_sshd)
    {:ok, state}
  end

  def handle_cast(:start_sshd, state) do
    Scaffold.RemoteShellDaemon.start_link
    {:noreply, state}
  end

  def handle_call({:log, level, str}, _from, state) do
    Logger.bare_log(level, str, [])
    {:reply, :ok, state}
  end
end
