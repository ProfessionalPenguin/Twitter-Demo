**Project 4.1 - Twitter Engine**

### Group Members

##### Rahul Bhatia UFID: 

Please refer the report for detailed information.

The Main driver file is server.ex

Program Description:
The goal of this was to implement a Twitter-like engine.


### Input Format:

Building and Execution instructions

To Run all the test cases

Naviagate into the folder project4
mix test


#### Functionality
Register the users.
Randomly choose some users to be logged in and some to be logged out.
Randomly choose followers for each user.
Predefine hashtags to be randomly chosen in each tweet.

Check if the user is logged in, if yes start publishing tweets.
-->Some tweets are @another _user or without a mention.
-->Send each tweet to the main server which then forwards it to all its followers and the @mentioned user.
-->Each node keeps publishing tweets till it reaches the max number defined.
-->The main server handles all the distribution of tweets.
-->As a node receives a tweet it adds it to its own feed.
-->Each tweet received is randomly retweeted based on a probability.
-->Retweets are also sent to the appropriate feeds.

If the user was logged out it does not send any tweets nor receive them live.
Once each node has sent out the required number of tweets the program stops sending further tweets.
For users that were logged out, we use queries and build up its feed by searching the ETS tables and matching it with the user they follow. We end up building a twitter feed that the user should have received
if they were logged in.

#### Test Cases
Check report for more detail.

