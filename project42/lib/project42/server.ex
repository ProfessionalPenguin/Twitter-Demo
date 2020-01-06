defmodule Project42.Server do
use GenServer
alias Project42.Accounts.User
alias Project42.Accounts

def start_link(_)do
  GenServer.start_link(__MODULE__, :no_args , name: :server)
end

def init(_) do
  :ets.new(:users, [:set, :public, :named_table]) # user struct
  :ets.new(:tweets, [:set, :public, :named_table])
  :ets.new(:hashtags, [:set, :public, :named_table])
  :ets.new(:mentions, [:set, :public, :named_table])
  :ets.new(:subscribers, [:set, :public, :named_table])
  :ets.new(:sockets, [:set, :public, :named_table])


 # register_users(10)

  #assign random subscribers
  #allUsers=Accounts.list_users()

 # IO.inspect(allUsers)
 for x <- 1..100 do
  pid=Project42.NodeSupervisor.add_node()
  user=%User{id: "#{inspect pid}", username: "USER"<>"#{inspect x}", password: "pass", pid: pid}
  :ets.insert_new(:users,{ "USER"<>"#{inspect x}",user } )
  :ets.insert_new(:subscribers,{ user , []} )
 end

  #start tweeting

  #print all users

  {:ok, {} }
end

def assign_subscribers(user, allUsers) do
  randomUsers=Enum.take_random(allUsers--[user], 2)
  :ets.insert_new(:subscribers , {user, randomUsers} )
  # subscribers=:ets.match_object(:subscribers, {user, :"$1"})

  # IO.inspect(List.flatten(subscribers))
end

def register_users(users) do
  nodeList=Enum.reduce(1..users, [], fn x , acc ->
    # choice=Enum.random(1..20)
    #login_status=if choice>=17 do false else true end
    acc ++ [{x,Project42.NodeSupervisor.add_node()}] end)

    Enum.each(nodeList, fn x->
      pid=elem(x,1)
      user_info=%User{id: "#{inspect elem(x,1)}", username: "user"<>"#{inspect elem(x,0)}", password: "pass", pid: pid}
    :ets.insert_new(:users,{ user_info } )
    :ets.insert_new(:mentions,{ elem(x,0), []} )
    end)

#  length(Enum.filter(nodeList, fn x -> elem(x,2) end))

end

def update_socket(user, socket) do
  :ets.insert(:sockets,{ user , socket} )
end

def show_sockets() do
  IO.inspect(:ets.match_object(:sockets, {:_, :_}))
end

def add_subscriber(user, subscriber) do
  :ets.insert(:subscribers,{ user , [subscriber]} )
end

def show_subscribers() do
  IO.inspect(:ets.match_object(:subscribers, {:_, :_}))
end

def getUserStruct(user) do
  Enum.at(List.flatten( :ets.match(:users, {user, :"$3"})),0)
end

def getSocket(user)do
  elem(Enum.at(:ets.match_object(:sockets, {user, :"$1"}),0),1)
end

def recordTweet(user, tweet) do
  listoftweets=Enum.at(:ets.match(:tweets, {user , :"$1"}),0)

  listoftweets= if listoftweets==nil do
    [tweet]
  else
    Enum.at(listoftweets,0)++[tweet]
  end

  :ets.insert(:tweets, {user, listoftweets})
end

def addMention(mentionList, tweet) do
  for x <- mentionList do
    listoftweets=Enum.at(:ets.match(:mentions, {x , :"$1"}),0)

    listoftweets= if listoftweets==nil do
      [tweet]
    else
      Enum.at(listoftweets,0)++[tweet]
    end

    :ets.insert(:mentions, {x, listoftweets})
  end
end

def addHashtag(hashtagList, tweet) do
  for x <- hashtagList do
    listoftweets=Enum.at(:ets.match(:hashtags, {x , :"$1"}),0)

    listoftweets= if listoftweets==nil do
      [tweet]
    else
      Enum.at(listoftweets,0)++[tweet]
    end

    :ets.insert(:hashtags, {x, listoftweets})
  end
end

def viewAllMentions()do
IO.inspect(:ets.match_object(:mentions, {:_, :_}))
end

def viewAllHashtags()do
IO.inspect(:ets.match_object(:hashtags, {:_, :_}))
end

def viewAllTweets()do
  IO.inspect(:ets.match_object(:tweets, {:_, :_}))
  end

def searchHashtags(hashtag) do
  :ets.match_object(:hashtags, {hashtag, :_})
end

def searchMentions(mention) do
  :ets.match_object(:mentions, {mention, :_})
end

def extracthashtags(s) do
  list = String.split(s," ")
  l = length(list)
  hashtaglist = Enum.filter(list, fn x-> String.slice(x,0,1) == "#" end)
  hashtaglist = unique(hashtaglist)
end

def extractmentions(s) do
  list = String.split(s," ")
  l = length(list)
  mentionslist = Enum.filter(list, fn x-> String.slice(x,0,1) == "@" end)
  mentionslist=Enum.map(mentionslist, fn x -> String.slice(x,1, String.length(x)) end)
  mentionslist = unique(mentionslist)
end

  def unique(list) do
    unique(list, HashSet.new)
  end

  defp unique([s | rest], match) do
    if HashSet.member?(match, s) do
      unique(rest, match)
    else
      [s | unique(rest, HashSet.put(match, s))]
    end
  end
  defp unique([], _) do
    []
  end

  def getTweets(user)do

  end
end
