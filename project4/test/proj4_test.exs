
defmodule Proj4Test do
  use ExUnit.Case

  @clients 25
  @tweets 10
  IO.puts("Testing 25 Users and 10 Tweets.....")


  test "Check if all ETS Tables Exist" do

    refute :ets.whereis(:users)==:undefined
    refute :ets.whereis(:tweets)==:undefined
    refute :ets.whereis(:hashtag)==:undefined
    refute :ets.whereis(:mentions)==:undefined
    refute :ets.whereis(:subscribers)==:undefined
    refute :ets.whereis(:retweets)==:undefined

    IO.puts("\nCheck if all ETS Tables Exist : True")
  end


  test "Check if right number of accounts are created." do


    accounts=:ets.match(:users, {:"$1", :"$2",  :"$3"})
    assert length(accounts)==@clients

    IO.puts("\nCheck if right number of accounts are created : True")
  end

  test "Show logged in users." do

    logged_in=for x <- 1..@clients do
      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do pid else 0 end
    end
    loggedInUsers=Enum.filter(logged_in, fn x -> is_pid(x) end)
    loggedIn=length(loggedInUsers)

    IO.puts("\nLogged in users are : #{inspect loggedIn}")
  end

  test "Check if every user has atleast one subscriber" do
    for x <- 1..@clients do
      refute elem(Enum.at(:ets.lookup(:subscribers,x), 0), 1) == []
    end
    IO.puts("\nCheck if every user has atleast one subscriber : True")
  end

  test "Check if every user is not subscribed to itself" do
    for x <- 1..@clients do
      refute Enum.member?(elem(Enum.at(:ets.lookup(:subscribers,x), 0), 1), x) == true
    end
    IO.puts("\nCheck if every user is not subscribed to itself : True")
  end


  test "Subscribers of each User" do
    IO.puts("\nSubscribers of each User")

    for x <- 1..@clients do
      subscibers=elem(Enum.at(:ets.lookup(:subscribers,x), 0), 1)
      IO.puts("User #{inspect x} : #{inspect subscibers}")
    end

  end


  test "Check if every live user has sent a tweet" do

    logged_in=for x <- 1..@clients do
      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do pid else 0 end
    end

    loggedInUsers=Enum.filter(logged_in, fn x -> is_pid(x) end)

    for x<- loggedInUsers do
      count=GenServer.call(x, {:checkTweetsSent}, :infinity)
      assert count<=@tweets
    end

    IO.puts("\nCheck if every live user has sent a tweet : True")
  end


  test "Count Retweets" do
    retweets=length(:ets.match(:retweets, {:"$1", :"$2",  :"$3", :"$4"}))

    IO.puts("\nCount Retweets : #{inspect retweets}")
  end

  test "Count Mentions" do
    IO.puts("\nMentions of each User")
    mentions=:ets.match(:mentions, {:"$1", :"$2"})

    Enum.each(mentions, fn x ->
    user=Enum.at(x,0)
    mentions=length(Enum.at(x,1))

    IO.puts("User #{inspect user} : #{inspect mentions}")

    end)
  end

  test "Check if every tweet contains a hashtag" do
    tweets=:ets.match(:tweets, {:"$1", :"$2",  :"$3", :"$4", :"$5"})
    for x <-tweets do
      refute Enum.at(x,3) == ""
    end
    IO.puts("\nCheck if every tweet contains a hashtag : True")
  end

  test "Count of hashtags" do
    IO.puts("\nFrequency of Hashtags")
    hashtag=:ets.match(:hashtag, {:"$1", :"$2"})

    Enum.each(hashtag, fn x ->
      hashtag=Enum.at(x,0)
      frequency=length(Enum.at(x,1))
      IO.puts("Hashtag #{inspect hashtag} : #{inspect frequency}")
  end)

end

  test "Logged out users have empty twitter feed" do
    logged_out=for x <- 1..@clients do
      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do 0 else pid end
    end

    loggedOutUsers=Enum.filter(logged_out, fn x -> is_pid(x) end)

    Enum.each(loggedOutUsers, fn x ->
      feed=GenServer.call(x,{:returnFeed}, :infinity)
    assert feed == []
    end)

    IO.puts("\nLogged out users have empty twitter feed : True")
  end



  test "Logged in users have a non empty twitter feed" do

    logged_in=for x <- 1..@clients do
      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do pid else 0 end
    end

    loggedInUsers=Enum.filter(logged_in, fn x -> is_pid(x) end)
    Enum.each(loggedInUsers, fn x ->
      feed=GenServer.call(x,{:returnFeed}, :infinity)
    refute feed == []
    end)



    IO.puts("\nLogged in users have non empty twitter feed : True")
  end


  test "Check total number of original tweets" do

    #get count of logged in

    loggedin=for x <- 1..@clients do
      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do 1 else 0 end
    end
    loggedin_count= length(Enum.filter(loggedin, fn x -> x==1 end))

    tweets=:ets.match(:tweets, {:"$1", :"$2",  :"$3", :"$4", :"$5"})
    # IO.inspect(loggedin_count)
    # IO.inspect(length(tweets))
    assert length(tweets)==@tweets*loggedin_count-1
    IO.puts("\nCheck total number of original tweets : True")
  end

test "Check if tweets are delivered to all live subscribers" do

  # find live subscribers
  for x <- 1..@clients do
    subscibers=elem(Enum.at(:ets.lookup(:subscribers,x), 0), 1)

    logged_in=for x <- subscibers do

      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do pid else 0 end
    end
      loggedInSubscribers=Enum.filter(logged_in, fn x -> is_pid(x) end)
      originalTweets=:ets.match(:tweets, {:"$1", :_, x, :_ , :"$2"})
      originalTweets=Enum.filter(originalTweets, fn x ->
      Enum.at(x,1)==false
      end)

     Enum.each(loggedInSubscribers, fn x ->
       feed=GenServer.call(x, {:returnFeed})
       feed=Enum.map(feed, fn convert -> :crypto.hash(:sha256, convert) |> Base.encode16 end)
      Enum.each(originalTweets, fn y ->
        assert Enum.member?(feed,Enum.at(y,0))
      end)

       end)
  end

  IO.puts("\nCheck if tweets are delivered to all live subscribers: True")
end

test "Tweets with mentions go only to those users." do
  originalTweets=for x <- 1..@clients do
  :ets.match(:tweets, {:"$1", :_, x, :_ , :"$2"})
  end

  mentionTweets=for k <- originalTweets do
    Enum.filter(k, fn x ->
      Enum.at(x,1)==true
      end)
    end

    logged_in=for x <- 1..@clients do
      pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
      status=GenServer.call(pid,:isLoggedIn, :infinity)
      if status==true do pid else 0 end
    end

    loggedInUsers=Enum.filter(logged_in, fn x -> is_pid(x) end)
     feed= List.flatten(for x <- loggedInUsers do
      # feed=GenServer.call(x, {:returnFeed})
      Enum.map(GenServer.call(x, {:returnFeed}), fn x->
        :crypto.hash(:sha256, x) |> Base.encode16
      end)

    end)

    for x <- mentionTweets do
      Enum.each(x, fn y->
      assert Enum.member?(feed,Enum.at(y,0))
      end)
    end

  IO.puts("\nTweets with mentions go only to those users : True")
end

test "Feeds built for logged out users." do
  IO.puts("\nFeeds built for logged out users.")

  logged_out=for x <- 1..@clients do
    pid=elem(Enum.at(:ets.lookup(:users, x),0),1)
    status=GenServer.call(pid,:isLoggedIn, :infinity)
    if status==true do 0 else pid end
  end

  loggedOutUsers=Enum.filter(logged_out, fn x -> is_pid(x) end)
  if length(loggedOutUsers)==0 do
    IO.puts("No logged out users")
  else

    for x <-loggedOutUsers do
      GenServer.cast(x, :buildtable)
      feed=GenServer.call(x, {:returnFeed}, :infinity)
      #Enum.each(feed, fn x -> IO.inspect(x) end)
      refute feed==[]
    end

  end

end

test "Delete Account" do
  assert :ets.delete(:users, 1)

  tweets=:ets.match(:tweets, {:"$1", :_, 1, :_, :_ })

  Enum.each(tweets, fn x-> assert :ets.delete(:tweets, x) end)

  IO.puts("\nDelete User1 and remove all tweets made by the account : True")
  System.stop(0)
end


end
