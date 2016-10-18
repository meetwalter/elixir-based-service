require Logger

defmodule Scaffold do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Scaffold.Server, []),
    ]

    opts = [strategy: :one_for_one, name: Scaffold.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Scaffold.Server do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: {:global, Scaffold.Server})
  end

  def init(state) do
    self |> GenServer.cast(:start_sshd)
    {:ok, state}
  end

  def handle_cast(:start_sshd, state) do
    ssh_config = System.get_env("SSH_VIA_GITHUB")
    if ssh_config do
      [github_team, github_token] = String.split(ssh_config, ":")
      ssh_keys = pull_github_ssh_keys!(github_team, github_token)
      start_ssh_daemon!(ssh_keys)
    end

    {:noreply, state}
  end

  def handle_call({:log, level, str}, _from, state) do
    Logger.bare_log(level, str, [])
    {:reply, :ok, state}
  end

  def log(level, str) do
    :global.whereis_name(__MODULE__) |> GenServer.call({:log, level, str})
  end


  def start_ssh_daemon!(authorized_keys) do
    File.mkdir_p!("/etc/ssh")

    System.cmd("ssh-keygen", ["-q", "-t", "rsa", "-P", "", "-f", "/etc/ssh/ssh_host_rsa_key"])

    File.open! "/etc/ssh/authorized_keys", [:write], fn(file) ->
      Enum.each authorized_keys, fn(key) ->
        IO.puts(file, key)
      end
    end

    Application.ensure_all_started :ssh
    {:ok, pid} = :ssh.daemon 22,
      shell: {IEx, :start, []},
      system_dir: '/etc/ssh',
      user_dir: '/etc/ssh',
      user_passwords: [],
      parallel_login: true,
      max_sessions: 30,
      connectfun: fn(username, _, method) ->
        Logger.info(["authenticated: ", IO.ANSI.format([:blue, username]), " (", method, ")"])
      end,
      failfun: fn(username, addr, reason) ->
        Logger.warn(["connection failed from ", username, "@", :inet.ntoa(elem(addr, 0)), ": ", inspect(reason)])
      end



    Process.link pid

    :ok
  end

  def pull_github_ssh_keys!(github_team, auth_token) do
    client = Tentacat.Client.new(%{access_token: auth_token})

    member_names = Tentacat.Organizations.Members.public_list(github_team, client) |> Enum.map(fn(u) -> u["login"] end)

    member_keys = Enum.map member_names, fn(username) ->
      Tentacat.Users.Keys.list(username, client) |> Enum.map(fn(k) -> k["key"] end)
    end

    List.flatten(member_keys)
  end
end
