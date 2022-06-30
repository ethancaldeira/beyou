import 'package:beyou/widgets/nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../utils/check_time.dart';
import '../utils/hex_color.dart';
import 'chats.dart';

//AllChatsPage is to show all the user has.
//Tutorial was used when creating this code, the code has been adapted from: https://www.youtube.com/watch?v=X00Xv7blBo0
class AllChatsPage extends StatefulWidget {
  const AllChatsPage({Key? key}) : super(key: key);
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<AllChatsPage> {
  //Needed as the database is accessed using the users id.
  final AuthService _auth = AuthService();
  //Used to store the data about a friend user from the firebase collection.
  Map<String, dynamic>? friendData;
  //Stores friends that have existing chats with current user.
  List<Map<String, dynamic>?> friendChat = [];
  //Stores chat id if there is an existing chats with current user.
  List<String> friendChatIds = [];
  //Stores friends that do not have chats with current user.
  List<Map<String, dynamic>?> noChat = [];
  //Boolean checks if the user has friends, sets to false automatically.
  bool noFriends = false;
  //Boolean checks if the user has friends without chats.
  bool hasFriendsWithNoChat = false;
  //Boolean checks if the chata data is empty.
  bool isChatDataEmpty = true;
  //Boolean checks if loading is happening.
  bool isLoading = false;
  //Stores the id of the current user.
  late String myId;

  @override
  void initState() {
    super.initState();
    //Checks if the user has passed their set time limit.
    checkTimeLimit(context);
    //Sets the current users id.
    setMyId();
    //Main function that finds the friends with chat data.
    findFriendsData();
  }

  //Simple function that is retrives the current users id.
  void setMyId() {
    //Function needed as _auth cannot be accessed in an initializer.
    setState(() {
      myId = _auth.getUid();
    });
  }

  //Method creates a new chat for the selected user.
  createNewChat(String friendId) async {
    //Takes the friends id as a parameter, creates a list with the current user id and the friend's id.
    List<String> users = [myId, friendId];

    //Creates a chat id for the chat between the two users.
    String chatId = '$myId\_$friendId';

    //Creates the Map that contains all the infomation to add to the database.
    Map<String, dynamic> newChatData = {
      "users": users, //List of the current and friends id.
      "chatId": chatId, //Creates the id between the two users.
    };
    //Using the DatabaseService class a chat can be created between the two users.
    DatabaseService(uid: myId).addChat(newChatData, chatId);
  }

  //Main method that finds the friends of the user and their chat data
  void findFriendsData() async {
    //Sets isLoading to true as the data is now being loaded from the database.
    setState(() {
      isLoading = true;
    });
    //Wait on the query from firebase, accessing the current users data, to find their friends.
    await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: myId)
        .get()
        .then(
            (value) //Once the query is done we then need to execute more code.
            async {
      //Checks if the user has friends, by seeing if the friends field is not empty.
      if (value.docs[0]["friends"].toString() != '[]') {
        //If the user does have friends we need to collect their data.
        for (var x in value.docs[0]["friends"]) {
          //For each of the ids inside the friends field we need to run another firebase query.
          //We are now collecting the friends data.
          friendData = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId,
                  isEqualTo:
                      x) // x matches to the correct id inside the friends array from current user.
              .get()
              .then(
                  (value) //Once this new query has run we need to execute more code.
                  async {
            //Creates a list that will store the current users chat data.
            List myChatsData = [];
            //Creates a local variable friendID which stores the current friends id.
            String friendId = value.docs[0].id;

            //Checks the current users chats.
            var myChats = await DatabaseService(uid: myId).getUserChats(myId);

            //Checks if the current user has chats, by checking myChats is not empty.
            if (myChats.docs.toString() != '[]') {
              //If the user does have chats.
              for (var x in myChats.docs) {
                //We add the data from myChats into the myChatsData.
                myChatsData.add(x['chatId']);
              }
            }
            //The id of the chats can either have the current users id first or the current friend id first -
            //This depends on which friend started the chat, but we need to check both formats to find the id.

            //We check if myChat data contains an exisiting chat with the current friend.
            if (myChatsData.contains("$myId\_$friendId")) {
              //If there is an existing chat with this friend we need to set that data from the chat.
              setState(() {
                //Adding this current friends data to friendData as there is an existing chat
                friendData = value.docs[0].data();
                //Adds a field for the id of the current friend.
                friendData!['id'] = value.docs[0].id;

                //Adds this friend data into a list that stores all the friend chats the current user has.
                friendChat.add(friendData);
                //Adds the chat id of this friends chat with the current user.
                friendChatIds.add("$myId\_$friendId");
                //As there are exisiting chats isChatDataEmpty is now false.
                isChatDataEmpty = false;
              });
            }
            //Now checking the other format of the chat id.
            else if (myChatsData.contains("$friendId\_$myId")) {
              //If there is an existing chat with this friend we need to set that data from the chat.
              //Same proccess as above will now take place.
              setState(() {
                //Set the friend data to the current friend, and add a field with the current friend id.
                friendData = value.docs[0].data();
                friendData!['id'] = value.docs[0].id;
                //Add the data into the friendChat list, also adds the other formatted id to friendsChatIds -
                //and isChatDataEmpty is now false as there is an exisiting chat.
                friendChat.add(friendData);
                friendChatIds.add("$friendId\_$myId");
                isChatDataEmpty = false;
              });
            }
            //If myChatsData contained neither of the formats there is no chat with this current friend.
            else {
              setState(() {
                //We still need to add this current friends data into FriendData, and a field for their id.
                friendData = value.docs[0].data();
                friendData!['id'] = value.docs[0].id;
                //Now that there is no chat between the two friends we add the current friends data into the list noChat
                noChat.add(friendData);
                //We also change the variable hasFriendsWithNoChat to true as there is a friend without a chat with the current user.
                hasFriendsWithNoChat = true;
              });
            }
          });
        }
        //Once we have finished looping through all the friends.
        //We change isLoading to false as we are no longer loading data from the database.
        setState(() {
          isLoading = false;
        });
      } //If the user does not have any friends.
      else {
        //We need to stop loading as there is nothing to load
        setState(() {
          isLoading = false;
          //We need to set noFriends to true as there were no friends found in the users data -
          //this allows us to show a prompt to the user to add friends instead of showing an empty page.
          noFriends = true;
        });
      }
    });
  }

  //Building the page that the user sees.
  @override
  Widget build(BuildContext context) {
    //If the loading has completed we can show the page contents.
    return isLoading == false
        ? Scaffold(
            //As this page is a main page we do not create an App Bar as it keeps it constant with the style of other main pages.
            body: Column(children: <Widget>[
              Row(
                children: const [
                  Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        top: 60,
                      ),
                      child: Text(
                        "Chats",
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ), //Instead of Appbar the same row text is used for this page as the other main pages on the nav bar.
              //Checks if the bool noFriends is false.
              noFriends == false
                  ? hasFriendsWithNoChat ==
                          true //If it is false we need to check if the user has no friend that they do not have a chat with, -
                      //by checking if hasFriendsWithNoChat is true.
                      ? //If it is true we need to give the user a chance to create a chat with these users.
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child:
                              //Create sized box that will conatin the boxs that show the friends user name and an add button to the user.
                              SizedBox(
                                  height: 90,
                                  //We need to build a list as there might be more than one of the friends that the user has no chats with.
                                  child: ListView.builder(
                                      scrollDirection: Axis
                                          .horizontal, //Scroll needs to be horizontal as it is ontop of the page.
                                      itemCount: noChat
                                          .length, //the length of the list is the same as the noChat list.
                                      //itemBuilder allows us to build the items that will appear in this list view.
                                      itemBuilder: (context, index) {
                                        //We need the user to be able to interact with these boxes, returning an InkWell allows for this.
                                        return InkWell(
                                          //When the InkWell is tapped we need code to execute as we need to create a chat between the friend and the current user.
                                          onTap: () async {
                                            //Creating a local variable to store the id of the clicked on friend.
                                            String friendId =
                                                noChat[index]!['id'];
                                            //Creating a local variable to store the name of the clicked on friend.
                                            String friendName =
                                                noChat[index]!['name'];
                                            //creating a new chat with the clicked on friend and current user.
                                            createNewChat(noChat[index]!['id']);
                                            //We need to create the new chat id betweem the two users.
                                            //The current user id first as they are creating the chat
                                            String chatId = '$myId\_$friendId';
                                            //Push the user to the new chat page.
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                          chatId:
                                                              chatId, //Setting chat id to the one we created earlier
                                                          userId:
                                                              myId, //Giving the page, the current users id.
                                                          friendName:
                                                              friendName, //Giving the page, the friends name.
                                                        )));
                                          },
                                          //Inside the inkwell we want to return a card that contains the friends details.
                                          child: Card(
                                            shadowColor:
                                                hexStringToColor("471dbc"),
                                            elevation: 8,
                                            clipBehavior: Clip.antiAlias,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                            ), //Set to the same style as the rest of the application, also making the card circular.
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    hexStringToColor("6c4ac9"),
                                                    hexStringToColor("5934c3"),
                                                    hexStringToColor("471dbc")
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ), //Same gradient used as the one used on the login and signup pages.
                                              //padding used so there is no overflow error when loading the friends user.
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ), //Have the add icon to indicate to the user they need to press the card in order -
                                                    //to create a chat with the user.
                                                    Center(
                                                        child: Text(
                                                      noChat[index]![
                                                          'username'], //Using the noChat list with the index of the list view so that the correct username is shown.

                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      //Styling to make the text stand out on the card.
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      })),
                        )
                      : Container() //If the user does not have a friend without a chat than we need to return and empty Container.
                  //This would mean that all the users friends have chats with the current user.
                  //Otherwise if the user has no friends a prompt must be shown
                  : Padding(
                      //Padding stops any overflow errors when showing the prompt on a smaller device.
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          Text(
                            'Add Friends to chat with them!', //Prompts the user to add friends as they have non currently.
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: hexStringToColor('471dbc'),
                                fontSize: 32),
                          ), //Text Styling makes the prompt large and close to the middle of the screen.
                        ],
                      ),
                    ),
              //Checking if chat data is empty.
              //It is intialised as empty by as the findFriendsData() method runs it is updated.
              //If there are chats we need to show the user who the chats are with.
              isChatDataEmpty == false
                  ? SizedBox(
                      height: 400,
                      //List view used as there may be multiple chats that the user has.
                      child: ListView.builder(
                          itemCount: friendChat
                              .length, //Sent the length to the friendChat list which was populated in the findFriendsData() method.
                          itemBuilder: (context, index) {
                            //Returning a ListTile makes it clear to the user they can interact with the item in the list.
                            return ListTile(
                              onTap: () async {
                                //Creating friend Id and friend name variables as they are used to push the user to the correct chat page.
                                String friendId = friendChat[index]!['id'];
                                String friendName = friendChat[index]!['name'];

                                //Checks the friendChatIds for which format id is used for these users chats.
                                if (friendChatIds
                                    .contains("$myId\_$friendId")) {
                                  //If the current users id is first, correct format need for the  Navigator.push()
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                                chatId: "$myId\_$friendId",
                                                userId: myId,
                                                friendName: friendName,
                                              )));
                                }
                                if (friendChatIds
                                    .contains("$friendId\_$myId")) {
                                  //If the friend id is first, correct format need for the  Navigator.push()
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              chatId: "$friendId\_$myId",
                                              userId: myId,
                                              friendName: friendName)));
                                }
                              },
                              title: Text(
                                friendChat[index]!['name'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ), //Show the users the name of the friend first.
                              ),
                              subtitle: Text(friendChat[index]![
                                  'username']), //As the subtitle it should be the friends username.
                              trailing: const Icon(Icons
                                  .chat), //Icon of chat used to show that it is a chat with the user.
                            );
                          }),
                    )
                  //Checking why the isChatDataEmpty is true, first checking if its because the user has no friends
                  : noFriends == false
                      //If the user has friends then isChatDataEmpty is empty because the user does not have any chats.
                      //Prompt to the user is needed
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 200.0,
                              left: 8,
                              right: 8,
                              bottom: 20), //Padding avoids an overflow error.
                          child: Text(
                              'Click on a friend above to start a chat with them',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hexStringToColor('471dbc'),
                                  fontSize:
                                      27)), //Same style used as the add friends prompt.
                        )
                      //If isChatDataEmpty is true because the user has no friends then we need to return
                      //- an empty Container as the other prompt will be shown.
                      : Container()
            ]),
            bottomNavigationBar:
                NavBar(index: 2), //The main nav bar as the other pages used.
          )
        //Show a CircularProgressIndicator while loading the data.
        : Scaffold(
            extendBody: true,
            body: Column(children: <Widget>[
              Row(
                children: const [
                  Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        top: 60,
                      ),
                      child: Text(
                        "Chats",
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 250.0,
                    left: 8,
                    right: 8,
                    bottom:
                        250), //Padding needed as there could be potential errors on other devices.
                child: CircularProgressIndicator(
                  color: hexStringToColor(
                      '471dbc'), //Same colour as the main one used in the app.
                ),
              )
            ]),
            bottomNavigationBar: NavBar(
                index:
                    2)); // Ensures that there is a nav bar as the page is loaded.);
  }
}

//Chat error needed incase there is an erro with creating a new chat.
createChatError(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return CupertinoAlertDialog(
          //Alerts the user to an error with creating a new chat.
          //This will show the user if there is a problem with creating a new chat..
          title: const Text("Chat Error"),
          content: Text(
            "\nThere was an error when creating the new chat, please try agian.\n\nHint:${error.toString()}",
          ),
        );
      });
}
