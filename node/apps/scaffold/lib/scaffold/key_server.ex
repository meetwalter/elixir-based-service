defmodule Scaffold.KeyServer do
  @moduledoc ~S"""
  Maps Erlangs `ssh_server_key_api` behaviour to a saner internal interface.
  """

  @behaviour :ssh_server_key_api

  @host_key_path "/etc/ssh/ssh_host_rsa_key"

  def host_key(:"ssh-rsa", options) do
    case File.read(@host_key_path) do
      {:ok, pem} ->
        IO.inspect "host_key exist"
        [rsa] = :public_key.pem_decode(pem)
        {:ok, :public_key.pem_entry_decode(rsa)}
      {:error, :enoent} ->
        IO.inspect "host_key does not exist"
        File.mkdir_p!(Path.dirname(@host_key_path))
        System.cmd("ssh-keygen", ["-q", "-t", "rsa", "-P", "", "-f", @host_key_path])
        host_key(:"ssh-rsa", options)
    end
  end

  def host_key(_, _), do: {:error, 'Not implemented!'}

  def is_auth_key(key, user, _opts) do
    IO.inspect {:is_auth_key, key, user, _opts}
    if GenServer.call(Scaffold.KeyServer, {:authenticate, :erlang.list_to_binary(user), key}) do
      GenServer.call(Scaffold.KeyServer, {:authorize, :erlang.list_to_binary(user), key})
    else
      false
    end
  end
end
