defmodule Project42.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Project42.Accounts.User
  alias Project42.HelperFunctions
  def list_users() do
    HelperFunctions.get_all_users_struct()

    #IO.inspect(allusers)
    # [
    #   %User{id: "1", username: "josevalim", password: "pass"},
    #   %User{id: "2", username: "redrapids", password: "pass"},
    #   %User{id: "3", username: "chrismccord", password: "pass"}
    # ]

   # IO.puts("#{inspect :ets.match(:users, {%{}})}")
  end

  def get_user(id) do
    Enum.find(list_users(), fn map -> map.id == id end)
  end

  def get_user_by(params) do
    Enum.find(list_users(), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end)
  end

  def create_user(username, password, pid) do
  #  IO.inspect(%User{id: pid, name: name, username: username, password: password})
  end

  def authenticate_username_password(username, password) do
    user=get_user_by(username: username)

    cond do
      user && user.password==password-> {:ok,user}
      user -> {:error, :unauthorized_access}
      true -> {:error, :not_found}
    end
  end
end
