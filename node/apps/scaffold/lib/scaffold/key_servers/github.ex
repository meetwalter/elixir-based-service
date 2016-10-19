defmodule Scaffold.KeyServer.Github do
  @moduledoc ~S"""
  Authenticates and authorizes via public keys on Github.
  """

  require Logger
  alias Logger, as: L

  use GenServer

  @doc false
  def start do
    GenServer.start(__MODULE__, {__MODULE__, []}, name: Scaffold.KeyServer)
  end

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, {__MODULE__, []}, name: Scaffold.KeyServer)
  end

  @doc false
  def init({name, []}) do
    config = config()
    L.warn "Allowing members of https://github.com/#{config[:organization]} to open remote shells!"
    {:ok, %{keys: keys_for_organization(config[:organization])}}
  end

  def handle_call({:authenticate, user, key}, _, %{keys: keys} = state) do
    # TODO(mtwilliams): Look up keys for user upon request and cache to ETS.
    {:reply, key in keys, state}
  end

  def handle_call({:authorize, user, key}, _, state) do
    # Assume they're authorized.
    {:reply, true, state}
  end

  alias Tentacat, as: Github

  # OPTIMIZE(mtwilliams): Extract into `init/1`.
  defp config do
    config = System.get_env("SSH_VIA_GITHUB")
    [organization, token] = String.split(config, ":")
    %{token: token, organization: organization}
  end

  defp client do
    Github.Client.new(%{access_token: config[:token]})
  end

  defp keys_for_organization(organization) do
    Github.Organizations.Members.public_list(organization, client)
    |> Enum.map(fn (member) -> keys_for_user(member["login"]) end)
    |> List.flatten
  end

  defp keys_for_user(user) do
    Github.Users.Keys.list(user, client)
    |> Enum.map(&(&1["key"]))
    |> Enum.map(&decode/1)
  end

  defp decode(key) do
    [decoded] = :public_key.ssh_decode(key, :public_key)
    decoded
  end
end
