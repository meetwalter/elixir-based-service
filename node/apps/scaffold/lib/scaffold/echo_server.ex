defmodule Scaffold.EchoServer do
  @moduledoc ~S"""
  """

  use GenServer

  def log(level, str) do
    :global.whereis_name(__MODULE__)
    |> GenServer.call({:log, level, str})
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:log, level, str}, _from, state) do
    Logger.bare_log(level, str, [])
    {:reply, :ok, state}
  end
end
