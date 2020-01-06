let Tweet = {
init(socket) {
    let channel = socket.channel("tweet:lobby", {})
    channel.join()
    
    this.listenForChats(channel)

    var x = document.getElementById("mainUser").value;
    channel.push('register', {name: x})


    
},

listenForChats(channel) {

    document.getElementById('tweet-form').addEventListener('submit', function(e){
      e.preventDefault()

      let userName = document.getElementById('mainUser').value
      let userTweet = document.getElementById('user-tweet').value

      channel.push('shout', {name: userName, body: userTweet})

     // document.getElementById('user-name').value = ''
      document.getElementById('user-tweet').value = ''
    })

    document.addEventListener('click',function(e){
      if(e.target && e.target.className== 'retweet'){
            //do something
            


            var userName = document.getElementById('mainUser').value
            //alert(e.target.id);
            
            var tweetbody=document.getElementsByClassName(e.target.id)[0].value
            
            let userTweet = "RETWEET : "+tweetbody
      
            channel.push('shout', {name: userName, body: userTweet})
      
           // document.getElementById('user-name').value = ''
            document.getElementById('user-tweet').value = ''
       }
   })


    document.getElementById('subscribers').addEventListener('keyup', function(e){
      if (e.keyCode === 13) {
        // Do something
        let userName = document.getElementById('mainUser').value
        let newSubscriberName=document.getElementById('newSubscriber').value

        if (userName==newSubscriberName) {
          alert("Cannot Follow Itself")
        }
        else{
          channel.push('addSubscriber', {name: userName, newSubscriber: newSubscriberName})
          
        }
        
    }

    })

    channel.on('subscriber_notValid', payload => {
      alert("Follower Not Valid")  
})

    channel.on('add_new_subscriber', payload => {
      alert("Follower Added")

          let subscriberblock=document.getElementById('subscribers')
          let newsubscriberElement=document.createElement('div')
          newsubscriberElement.insertAdjacentHTML('beforeend', payload.newSubscriber)
          subscriberblock.appendChild(newsubscriberElement)
      
    })


    document.getElementById('searchHashTag').addEventListener('keyup', function(e){
      if (e.keyCode === 13) {
        // Do something
      //  let userName = document.getElementById('mainUser').value
      //  alert("subscriber added");
        let hashTag=document.getElementById('searchHashTag').value
        channel.push('searchHashTag', {hashTag: hashTag})

        let hashTagResults=document.getElementById('hashTagResults')
        hashTagResults.innerHTML = "";
        let newElement=document.createElement('div')
        let message="All Tweets containing : " + hashTag
        newElement.insertAdjacentHTML('beforeend', message)
        hashTagResults.appendChild(newElement)
    }

    })

    document.getElementById('searchMentions').addEventListener('keyup', function(e){
      if (e.keyCode === 13) {
        // Do something
      //  let userName = document.getElementById('mainUser').value
      //  alert("subscriber added");
        let mention=document.getElementById('searchMentions').value
        channel.push('searchMentions', {mention: mention})

        let mentionResults=document.getElementById('mentionResults')
        mentionResults.innerHTML = "";
        let newElement=document.createElement('div')
        let message="All Tweets containing : " + mention
        newElement.insertAdjacentHTML('beforeend', message)
        mentionResults.appendChild(newElement)
    }

    })
    
    
    
    //retweet



    channel.on('shout', payload => {
        let feed = document.querySelector('#feed')
        let msgBlock = document.createElement('p')
        //msgBlock.className=new Date().getTime();


        var input = document.createElement("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", "name_you_want");
        input.setAttribute("value", "<b>"+payload.name+":</b> "+payload.body);
        input.className=new Date().getTime();
        msgBlock.appendChild(input);

        var d = new Date().getHours() +":"+new Date().getMinutes()+ "  "+ new Date().getDate() + "-" + + new Date().getMonth() + "-"+ new Date().getFullYear();
        msgBlock.insertAdjacentHTML('beforeend', `<b>${payload.name}:</b> ${payload.body} <sub style="background-color:LightGray;" >${d} </sub><button style="font-size: 8px; padding:0;" class="retweet" id="${input.className}">RETWEET</button>`)
        feed.appendChild(msgBlock)
        channel.push('publishTweet', payload)
      })

      channel.on('hashTagResults', payload => {
        let hashTagResults=document.getElementById('hashTagResults')
        let msgBlock=document.createElement('div')
        msgBlock.insertAdjacentHTML('beforeend', `${payload.hashTagResults}`)
        hashTagResults.appendChild(msgBlock)
      })

      channel.on('mentionResults', payload => {
        let mentionResults=document.getElementById('mentionResults')
        let msgBlock=document.createElement('div')
        msgBlock.insertAdjacentHTML('beforeend', `${payload.mentionResults}`)
        mentionResults.appendChild(msgBlock)
      })
  }

  

}


export default Tweet