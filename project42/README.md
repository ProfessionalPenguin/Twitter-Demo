**Project 4.2 - Twitter Engine implementation using Phoenix framework**

### Group Members

##### Rahul Bhatia UFID: 

Program Description:
The goal of this was to implement a user interface for the simulator created in project 4.1 using Phoenix that allows access to the ongoing simulation using a web browser.

#### Phoenix installation steps:
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


#### Functionalities

Register the users -> A user needs to be registered to log in. As soon as the user gets registered, a list of existing user pops up on the screen. The user can click "Login" with the specific username to login to the system

As soon as the user logs in, following are the activities which she/he can perform:
    1. Tweet -> User can write a tweet and post using the "Post" button. This tweet will appear in her/his own feed.
                This same tweet will be visible to all the subscribers of the current user.
    2. Followers -> Current user can write in the followers textbox a user which it would like to be its subscriber. 
            -If the user doesn't exist, there is an alert which specifies "Invalid user"
            -If the user types his own username, there is an alert which says "Cannot follow itself"
            -If none of the above holds true, current user successfully the gets the follower
    3. Mentions -> A tweet may or may not have a mention.
            -Irrespective of whether the current user follows the user it's mentioning, the same tweet would appear on the        feed of the user mentioned. 
            -The tweet doesn't get added to user's feed if the mentioned user doesn't exist
            -The current user can also mention the user to which it is subscribed to.
            -The current user can search for all the mentions of a given user using the "Mentions search box"
    4. Hashtags -> A tweet may or may not have a hashtag
            -The current user can search for a specific hashtag using the "Hashtags search box"
    5. Retweets -> Every tweet appearing on user feed has the fuctionality of being retweeted.
            -If the current user retweets some tweet, tweet gets added to its own feed
            -If the retweet contains a mention, tweet gets added to the mentioned user
    6. Logout to end the session and reset.        

Please refer the video link for more details -> https://youtu.be/UL-DzQU4wvo


