defmodule Proj4.Node do
  use GenServer

  def start_link(login_status) do
    GenServer.start_link(__MODULE__, login_status)
  end


  def init(login_status) do
   # IO.puts("Login Status: #{inspect login_status}")
    {:ok, login_status}
  end

  def handle_cast({:startTweeting, nodeUserID, users, messages, hashTagList}, login_status) do

    if login_status do

      randomtext=random_text()
      randomhashtag=Enum.random(hashTagList)
      choice=Enum.random(0..1)

      mention= if choice==0 do false else true end

      randomuser=if choice==0 do
        ""
      else
        list1=if nodeUserID-1==0 do [] else 1..nodeUserID-1 end
        list2=if nodeUserID==users do [] else nodeUserID+1..users end
        Enum.random(Enum.to_list(list1)++Enum.to_list(list2))
      end



      tweet=  if choice==0 do
        "user"<>"#{inspect nodeUserID}"<>" tweets: "<>randomtext<>" "<>randomhashtag
      else
        "user"<>"#{inspect nodeUserID}"<>" tweets: "<>randomtext<>" @user"<>"#{inspect randomuser}"<>" "<>randomhashtag
        end


      tweetID=:crypto.hash(:sha256, tweet) |> Base.encode16
      #tell main server about tweet
      Proj4.Server.recieve_tweet(tweet,tweetID,nodeUserID,randomuser, randomhashtag, mention, false)
      {:noreply, { nodeUserID, users ,messages-1, hashTagList, [tweet], login_status} }
      else
        {:noreply, { nodeUserID, users ,messages, hashTagList, [], login_status} }
    end

  end

  def handle_cast({:sendnexttweet}, {nodeUserID,users ,messages, hashTagList, feed, login_status}) do

    if login_status do
    if messages>0 do
      randomtext=random_text()
      randomhashtag=Enum.random(hashTagList)
      choice=Enum.random(0..1)
      mention= if choice==0 do false else true end

      randomuser=if choice==0 do "" else
        list1=if nodeUserID-1==0 do [] else 1..nodeUserID-1 end
        list2=if nodeUserID==users do [] else nodeUserID+1..users end
        Enum.random(Enum.to_list(list1)++Enum.to_list(list2))
      end

      tweet=  if choice==0 do
        "user"<>"#{inspect nodeUserID}"<>" tweets: "<>randomtext<>" "<>randomhashtag
      else
        "user"<>"#{inspect nodeUserID}"<>" tweets: "<>randomtext<>" @user"<>"#{inspect randomuser}"<>" "<>randomhashtag
        end

    tweetID=:crypto.hash(:sha256, tweet) |> Base.encode16

    #tell main server about tweet
    Proj4.Server.recieve_tweet(tweet,tweetID,nodeUserID,randomuser, randomhashtag, mention, false)
    {:noreply, { nodeUserID, users ,messages-1, hashTagList, feed++[tweet], login_status} }
    else
    {:noreply, { nodeUserID, users ,messages-1, hashTagList, feed, login_status} }
  end
else

  {:noreply, { nodeUserID, users ,messages, hashTagList, feed, login_status} }
end

  end

  def handle_cast({:retweet, tweet, hashtag}, { nodeUserID, users ,messages, hashTagList, feed, login_status} ) do
    retweet="RETWEET by user"<>"#{inspect nodeUserID}"<>" =>"<>tweet
    tweetID=:crypto.hash(:sha256, retweet) |> Base.encode16

    Proj4.Server.recieve_tweet(retweet,tweetID,nodeUserID,"", hashtag, false, true)
    :ets.insert_new(:retweets, {tweetID, retweet, nodeUserID, hashtag} )
    {:noreply, { nodeUserID, users ,messages, hashTagList, feed++[retweet], login_status} }
  end

  def handle_cast({:recievetweet, tweet , hashtag}, {nodeUserID, users ,messages, hashTagList, feed, login_status}) do
    if login_status do
    #choose randomyl to retweet
    choice=Enum.random(1..20)
    if choice>=19  do
      pid=elem(Enum.at(:ets.lookup(:users, nodeUserID),0),1)
      GenServer.cast(pid, {:retweet, tweet, hashtag})
    end

    {:noreply, { nodeUserID, users ,messages, hashTagList, feed++[tweet], login_status} }
  else
    {:noreply, { nodeUserID, users ,messages, hashTagList, feed, login_status} }
  end

  end

  def handle_cast({:printFeed}, {nodeUserID, users ,messages, hashTagList, feed, login_status}) do
    #print feed
    IO.puts("#{inspect nodeUserID} #{inspect feed}")

    {:noreply, {nodeUserID, users ,messages, hashTagList, feed, login_status}}
  end


  def handle_cast(:buildtable, {nodeUserID, users ,messages, hashTagList, feed, login_status})do
    if !login_status do
      feed=buildfeed(nodeUserID)
      {:noreply, {nodeUserID, users ,messages, hashTagList, feed, login_status}}
    else
      {:noreply, {nodeUserID, users ,messages, hashTagList, feed, login_status}}
    end
  end


  def buildfeed(nodeUserID) do
   subscriberTable=:ets.match(:subscribers, {:"$1", :"$2"})
   subscribedTo= Enum.filter(subscriberTable, fn x-> nodeUserID in Enum.at(x,1) end)

   subscribedToList=Enum.map(subscribedTo, fn x -> Enum.at(x,0) end)


   List.flatten(Enum.map(subscribedToList, fn x ->  :ets.match(:tweets, {:_, :"$1", x, :_, :_})end))

  end
    def random_text() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)
    max|> Kernel.-(min)|> :rand.uniform()|> Kernel.+(min)|> Integer.to_string(36)
  end

  def handle_call({:returnFeed}, _from, {nodeUserID, users ,messages, hashTagList, feed, login_status}) do
    {:reply,feed, {nodeUserID, users ,messages, hashTagList, feed, login_status}}
  end


  def handle_call({:checkTweetsSent}, _from, {nodeUserID, users ,messages, hashTagList, feed, login_status}) do
    {:reply, messages,{nodeUserID, users ,messages, hashTagList, feed, login_status}}
  end

  def handle_call(:isLoggedIn, _from,{nodeUserID, users ,messages, hashTagList, feed, login_status} ) do
    {:reply, login_status,{nodeUserID, users ,messages, hashTagList, feed, login_status}}
  end

  end




