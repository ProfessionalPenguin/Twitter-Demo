defmodule Project42Web.UserView do
  use Project42Web, :view

  alias Project42.Accounts

  def get_username(%Accounts.User{username: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

  def get_password(%Accounts.User{password: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

  def get_id(%Accounts.User{id: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

end
