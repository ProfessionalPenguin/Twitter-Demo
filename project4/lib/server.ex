defmodule Proj4.Server do
use GenServer

def start_link(args)do
  GenServer.start_link(__MODULE__, args, name: __MODULE__)
end


def init({users, messages}) do

  :ets.new(:users, [:set, :public, :named_table])
  :ets.new(:tweets, [:set, :public, :named_table])
  :ets.new(:hashtag, [:set, :public, :named_table])
  :ets.new(:mentions, [:set, :public, :named_table])
  :ets.new(:subscribers, [:set, :public, :named_table])
  :ets.new(:retweets, [:set, :public, :named_table])

  #define hasthtags
  hashTagList=["#DOS1", "#DOS2", "#DOS3", "#DOS4", "#DOS5"]
  :ets.insert_new(:hashtag, {"#DOS1", [] })
  :ets.insert_new(:hashtag, {"#DOS2", [] })
  :ets.insert_new(:hashtag, {"#DOS3", [] })
  :ets.insert_new(:hashtag, {"#DOS4", [] })
  :ets.insert_new(:hashtag, {"#DOS5", [] })

  # message="Registering Users"
  # IO.puts("#{inspect message}")
  loggedinusers=register_users(users)

  # message="Assigning Subscribers"
  # IO.puts("#{inspect message}")
  assign_subscribers(users)

  #send cast to each node to start tweeting with no of users, messages and hashtagList
  for x <-1..users do
    pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
    GenServer.cast(pid, {:startTweeting, x, users, messages, hashTagList})
  end

  tweetsSent=0
  {:ok, {users, loggedinusers, messages, tweetsSent} }
end


def register_users(users) do

  nodeList=Enum.reduce(1..users, [], fn x , acc ->
    choice=Enum.random(1..20)
    login_status=if choice>=17 do false else true end
    acc ++ [{x,Proj4.NodeSupervisor.add_node(login_status), login_status}] end)


  Enum.each(nodeList, fn x->
  pid=elem(x,1)
  :ets.insert_new(:users,{ elem(x,0), pid, "#{inspect pid}"} )
  :ets.insert_new(:mentions,{ elem(x,0), []} )
  end)

  length(Enum.filter(nodeList, fn x -> elem(x,2) end))

end

def assign_subscribers(users) do

  for x <- 1..users do
    list1=if x-1==0 do [] else 1..x-1 end
    list2=if x==users do [] else x+1..users end

    randomUsers=Enum.take_random(Enum.to_list(list1)++Enum.to_list(list2), Enum.random(1..users))

    :ets.insert_new(:subscribers, { x,  randomUsers } )
  end
end

def delete_accounts(user)do
  :ets.delete(:users, user)
  :ets.match(:tweets, {:"$1", :_, 1, :_, :_ })
end

def recieve_tweet(tweet,tweetID,tweetSender,tweetReciever, hashtag, mention, retweet) do
  GenServer.cast(__MODULE__, {:recieveTweet, tweet,tweetID,tweetSender, tweetReciever, hashtag, mention, retweet})
end

def handle_cast({:recieveTweet, tweet,tweetID, tweetSender, tweetReciever, hashtag, mention, retweet}, {users, loggedinusers, messages, tweetsSent}) do

  if tweetsSent<messages*loggedinusers-1 do

  if !retweet do
  :ets.insert_new(:tweets, {tweetID, tweet, tweetSender, hashtag, mention} )
  tweetIDlist= elem(Enum.at(:ets.lookup(:hashtag, hashtag),0),1)++[tweetID]
  :ets.insert(:hashtag, {hashtag, tweetIDlist })
  end


  if mention do
  tweetIDlist=elem(Enum.at(:ets.lookup(:mentions, tweetReciever),0),1)++[tweetID]
  :ets.insert(:mentions, {tweetReciever, tweetIDlist })

  pid=elem(Enum.at(:ets.lookup(:users, tweetReciever),0),1)
  GenServer.cast(pid, {:recievetweet, tweet , hashtag})

  else
    #alert the subscribers
    subscribers=elem(Enum.at(:ets.lookup(:subscribers, tweetSender),0),1)
    Enum.each(subscribers, fn x ->  pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
    GenServer.cast(pid, {:recievetweet, tweet , hashtag})
    end)
  end

  pid=elem(Enum.at(:ets.lookup(:users, tweetSender),0),1)
  GenServer.cast(pid, {:sendnexttweet})

  # else
  #   #finish the program
  #   #each ndoe to print feed

  #   # message="END OF EXECUTION \n PRINTING ALL THE FEEDS"
  #   # IO.puts("#{inspect message}")
  #   for x <- 1..users do
  #     pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
  #   #   GenServer.cast(pid, :buildtable)
  #   #  feed=GenServer.call(pid, {:returnFeed}, :infinity)
  #   #  subscribers=elem(Enum.at(:ets.lookup(:subscribers, x),0),1)
  #   #   IO.puts("\n user #{inspect x} feed : subscribers #{inspect subscribers}")
  #   #   Enum.each(feed, fn x -> IO.inspect(x) end)


  #   end
  #   #System.halt(0)


  end


  if retweet do
    {:noreply, {users, loggedinusers, messages, tweetsSent}}
  else
    {:noreply, {users, loggedinusers, messages, tweetsSent+1}}
  end
end


end

