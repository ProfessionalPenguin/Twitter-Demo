defmodule Project42Web.TweetChannel do
  use Project42Web, :channel

  def join("tweet:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("tweet:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end


  def handle_in("register", payload, socket) do

   Project42.Server.update_socket(payload["name"], socket)
   Project42.Server.show_sockets()
   {:noreply, socket}
  end

  def handle_in("addSubscriber", payload, socket) do

      currentuser=payload["name"]
      newSubscriber=payload["newSubscriber"]
      subscriber=:ets.match(:users, {payload["newSubscriber"], :"$3"})
      subscriber=Enum.at(List.flatten(subscriber),0)
      IO.inspect(subscriber)
      if currentuser==newSubscriber or subscriber==nil do
        push socket, "subscriber_notValid" , payload
      else
      userstruct= currentuser |>Project42.Server.getUserStruct()

      Project42.Server.add_subscriber(userstruct, subscriber)
      Project42.Server.show_subscribers()
      push socket, "add_new_subscriber" , payload
      end


       {:noreply, socket}
    end

    def handle_in("searchHashTag", payload, socket) do
      hashtag=payload["hashTag"]
      hashTagResults=Enum.at(Project42.Server.searchHashtags(hashtag),0)
      hashTagResults=elem(hashTagResults,1)
      IO.inspect(hashTagResults)

      hashTagResults= Enum.map_reduce(hashTagResults, "", fn x, acc -> {x, x<>"<br/>"<>acc} end)

      hashTagResults=elem(hashTagResults,1)
      push socket , "hashTagResults" ,%{hashTagResults: hashTagResults}
         {:noreply, socket}
      end

      def handle_in("searchMentions", payload, socket) do
        mention=payload["mention"]
        mention=String.slice(mention,1, String.length(mention))
        IO.inspect(mention)

        mentionResults=Enum.at(Project42.Server.searchMentions(mention),0)
        mentionResults=elem(mentionResults,1)
        IO.inspect(mentionResults)
        # payload["hashTag"]=hashTagResults

        mentionResults= Enum.map_reduce(mentionResults, "", fn x, acc -> {x, x<>"<br/>"<>acc} end)

        mentionResults=elem(mentionResults,1)
        push socket , "mentionResults" ,%{mentionResults: mentionResults}
           {:noreply, socket}
        end

  def handle_in("shout", payload, socket) do

    tweet=payload["body"]
    IO.inspect(tweet)

    hashTagList=tweet|>Project42.Server.extracthashtags()
    Project42.Server.addHashtag(hashTagList, tweet)
    Project42.Server.viewAllHashtags()

    mentionsList=tweet|>Project42.Server.extractmentions()
    Project42.Server.addMention(mentionsList, tweet)
    Project42.Server.viewAllMentions()

   IO.inspect(payload)

   user=payload["name"]
   userstruct= user |>Project42.Server.getUserStruct()

   subscribers=Enum.at(:ets.match_object(:subscribers, {userstruct, :"$1"}),0)


   subscribers=elem(subscribers,1)
   subscribers=Enum.at(subscribers,0)
   IO.inspect(subscribers)

   if length(mentionsList)>0 do

    IO.inspect(mentionsList)
    for mention <- mentionsList do
      targetSocket=Project42.Server.getSocket(mention)
      if mention==user do
        push socket, "shout", payload
      else
        push targetSocket, "shout", payload
        push socket, "shout", payload
      end


    end

   else
    IO.inspect("check2")


    if subscribers==nil do
      push socket, "shout", payload
     else
      subscriberSocket=subscribers.username|> Project42.Server.getSocket()
      push subscriberSocket , "shout" , payload
      push socket, "shout", payload
     end

   end



    {:noreply, socket}
  end

  def handle_in("publishTweet", payload, socket) do
    Project42.Server.recordTweet(payload["name"], payload["body"])

    Project42.Server.viewAllTweets()
       {:noreply, socket}
    end


end
