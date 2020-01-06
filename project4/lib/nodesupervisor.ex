defmodule Proj4.NodeSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

   def add_node(login_status) do
     {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {Proj4.Node, login_status} )
    pid
    end
end
