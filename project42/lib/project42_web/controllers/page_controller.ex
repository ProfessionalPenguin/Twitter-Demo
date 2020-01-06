defmodule Project42Web.PageController do
  use Project42Web, :controller

  def index(conn, _params) do
    name="twitter"
   # render(conn, "index.html", name: name)
    conn|>redirect(to: Routes.user_path(conn, :index))
  end
end
