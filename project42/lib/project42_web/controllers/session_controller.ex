defmodule Project42Web.SessionController do
  use Project42Web, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}} ) do
    case Project42.Accounts.authenticate_username_password(username, password) do
      {:ok, user} ->
        conn
        |> Project42Web.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.user_path(conn, :show, user.id))

        #|> redirect(to: Routes.page_path(conn, :index))
      conn.assigns.current_user.id
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params)do
    conn
    |> Project42Web.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
