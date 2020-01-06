defmodule Project42.HelperFunctions do

  def get_all_users_struct()do
    users=:ets.match(:users, {:_, :"$3"})
    allusers=for x <- users do
      Enum.at(x,0)
    end

  end

end
