defmodule Scaffold.RemoteShellDaemon do
  @moduledoc ~S"""
  Exposes IEx over SSH.
  """

  require Logger
  alias Logger, as: L

  use GenServer

  @doc false
  def start do
    GenServer.start(__MODULE__, {__MODULE__, []}, name: __MODULE__)
  end

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, {__MODULE__, []}, name: __MODULE__)
  end

  @doc false
  def init({name, []}) do
    Scaffold.KeyServer.Github.start_link

    Application.ensure_all_started(:ssh)

    {:ok, pid} = :ssh.daemon(22,
      shell: {IEx, :start, []},
      system_dir: '/etc/ssh',
      user_dir: '/etc/ssh',
      user_passwords: [],
      auth_methods: 'publickey',
      parallel_login: true,
      max_sessions: 25,
      key_cb: Scaffold.KeyServer,
      connectfun: &on_success/3,
      failfun: &on_failure/3)

    Process.link(pid)

    {:ok, []}
  end

  defp on_success(username, address, method) do
    ip = :inet.ntoa(address)
    L.info(["Authenticated ", IO.ANSI.format([:blue, username, "@", ip]), "via ", method, "."])
  end

  defp on_failure(username, address, reason) do
    ip = :inet.ntoa(address)
    L.warn(["Connection failed from ", IO.ANSI.format([:blue, username, "@", ip]), " because: ", inspect(reason)])
  end
end
