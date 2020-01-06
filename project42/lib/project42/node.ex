defmodule Project42.Node do
  use GenServer

  def start_link(tweets) do
    GenServer.start_link(__MODULE__, tweets)
  end

  def init(tweets) do
    # IO.puts("Login Status: #{inspect login_status}")
     {:ok, tweets}
   end

end
