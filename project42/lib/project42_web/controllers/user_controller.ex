defmodule Project42Web.UserController do
  use Project42Web, :controller
  alias Project42.Accounts.User
  alias Project42.Accounts
  #plug :authenticate when action in [:index, :show]

  def index(conn, _params) do
    #IO.inspect(conn.assigns.current_user)
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => pid}) do

     user = Accounts.get_user(pid)

    subscribers=:ets.match_object(:subscribers, {user, :"$1"})
    IO.inspect(subscribers)
    subscribers=List.flatten(subscribers)
    subscribers=Enum.at(subscribers,0)


    render(conn, "show.html", data: subscribers )
  end

  def new(conn, _params)do
    render(conn, "new.html")
  end

  def create(conn, params) do
    # Accounts.create_user(params["username"], params["name"],params["password"],params["id"])
    pid=Project42.NodeSupervisor.add_node()
    user=%User{id: "#{inspect pid}", username: params["username"], password: params["password"], pid: pid}
    :ets.insert_new(:users,{ params["username"],user } )
    :ets.insert_new(:subscribers,{ user , []} )
    conn
    |>Project42Web.Auth.login(user)
    |>put_flash(:info, "#{inspect params["username"]} account created!")|> redirect(to: Routes.user_path(conn, :index))
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
