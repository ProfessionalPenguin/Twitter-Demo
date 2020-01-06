defmodule Proj4.Proj4 do
  use Application

  def start(_type, _args) do
    #  args = System.argv()
    #  users = String.to_integer(Enum.at(args, 0))
    #  messages = String.to_integer(Enum.at(args, 1))
    System.no_halt(true)

    children =

        [ Proj4.NodeSupervisor,
          {Proj4.Server , {25,10} }
        ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Assign2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
