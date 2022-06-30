import 'package:beyou/screens/other_users_page.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/database.dart';

//Tutorial followed to create page: https://www.youtube.com/watch?v=RaACAwvZ61E
//Code was adapted from the tutorial.
//SearchDelegate for the user search page.
class UserSearch extends SearchDelegate<String> {
  //Need auth so we can query the database for users.
  final AuthService _auth = AuthService();
  //Need a list to store the users in.
  final userList = [''];
  //Need a list to store recent searches in.
  final recentUsers = [''];
  //Need the a Map to store the search user data.
  Map<String, dynamic>? userSearched;
  //We have not sent a request to a user so that is also false.
  bool sentRequest = false;
  //We have not received a request from a user yet.
  bool receivedRequest = false;
  //We are not friends with users just yet.
  bool areFriends = false;
  //Bool value to check if there are no results.
  bool noSearchedResults = false;
  //Bool value checks if the user has searched themselves.
  bool selfSearch = false;

  //Method populates the userList
  createSearchList() async {
    //Create a variable to store all the users data from the users collection in firebase.
    var users = await FirebaseFirestore.instance.collection('users').get();
    //Checks each of the users inside the user varaible.
    for (var x in users.docs) {
      //Checks if the userList contains the username from x user.
      if (userList.contains(x['username'])) {
        break; //If it does break the for loop.
      }
      //If it does not then we can add the users data.
      else {
        //We need to remove the initial element from the list.
        //This element is used as a placeholder for when the list is populated.
        userList.remove('');
        //Adds the username for user x for the first time to the list.
        userList.add(x['username']);
      }
    }
  }

//Build the actions for the search.
  @override
  List<Widget> buildActions(BuildContext context) => [
        //Need a cancel search button.
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            //Checks if the search query is empty.
            if (query.isEmpty) {
              close(context, "null");
            } else {
              //If it is not empty we need to empty it, as the cancel acts as a reset search button.
              query = "";
              //Set query to nothing.
              recentUsers.remove('');
              //Remove the recent '' from recent user search.
              //Show the suggestions to the user.
              showSuggestions(context);
            }
          },
        )
      ];

//Need a back button for the user.
  @override
  Widget buildLeading(BuildContext context) => IconButton(
        //Same back button used as other pages throughout the app.
        icon: const Icon(Icons.arrow_back_ios),
        //When it is pressed we need to close the class.
        onPressed: () => close(context, "null"),
      );

  //We need to return something to indicate that there is no results.
  returnNoResults() {
    if (noSearchedResults == true) {
      //If there is no results for the user search we need to show that to the user.
      //Padding used to avoid an overflow error and to ensure the -
      //text is spaced from the search bar.
      return const Padding(
        padding: EdgeInsets.only(top: 25.0, left: 10, right: 10),
        child: Text('No Results, Please Try Again!'),
      );
    }
    //The user may try search themselves.
    if (selfSearch == true) {
      //If they do we need to inform them that they cannot search themselves.
      //Padding used to avoid an overflow error and to ensure the -
      //text is spaced from the search bar.
      return const Padding(
        padding: EdgeInsets.only(top: 25.0, left: 10, right: 10),
        child: Text('You cannot search yourself! Try searching another user!'),
      );
    } else {
      //If neither is true then we return a container.
      return Container();
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    //Checking if the recent query has not been searched.
    if (!recentUsers.contains(query)) {
      recentUsers.remove('');
      recentUsers.add(query);
    }

    //We need a to return a FutureBuilder that will show the results of the database query for the searched user.
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where("username",
              isEqualTo:
                  query) //Querying against our own search text or 'query'.
          .get()
          .then((value) async {
        //We need the current users username to avoid a self search.
        String currentUsername =
            await DatabaseService(uid: _auth.getUid()).retreiveUsername();

        //Need these bool values to be set to false as we find the information from the database -
        //we can change the values.
        sentRequest = false;
        receivedRequest = false;
        areFriends = false;

        //Set the Map to null, so we can populate it.
        userSearched = null;

        //Once we get the data from the database we can check if it is not empty.
        if (value.docs.toString() != '[]') {
          //If the data is not equal to an empty array it means that there is data there.
          if (value.docs[0].data()['username'] == currentUsername) {
            //If the username of the searched user matches the current usersname then it is a self search.
            //Keep userSearched equal to null;
            //Set selfSearch to true.
            selfSearch = true;
          }
          //If it is not a self search.
          else {
            //We need to check if this searched user has been sent a request from the current user or not.
            if (value.docs[0].data()['received_requests'].contains(_auth
                .getUid())) //Checking if the searched user has been sent a request from current user.
            {
              //If they have we can populate the data.
              userSearched = value.docs[0].data();
              userSearched!['id'] = value.docs[0]
                  .id; //Setting the id of this user, so that we can visit the user.
              //We set the value sentRequest true because the user has sent a request to this searched user.
              sentRequest = true;
            }
            //We need to check if the current user has sent the search user a request.
            else if (value.docs[0].data()['sent_requests'].contains(_auth
                .getUid())) //Checking if the searched user has received a request from current user.
            {
              //If they have we can populate the data.
              userSearched = value.docs[0].data();
              userSearched!['id'] = value.docs[0].id;
              //We set the value receivedRequest true because the current user has sent a received a request from this searched user.
              receivedRequest = true;
            }
            //We need to check that the searched user and current user are friends.
            else if (value.docs[0].data()['friends'].contains(_auth
                .getUid())) //Checking if the searched user has current user inside their friends list.
            {
              //If they do we can populate the data.
              userSearched = value.docs[0].data();
              userSearched!['id'] = value.docs[0].id;
              //We can set areFriends to true as they are friends.
              areFriends = true;
            }
            //Else if the searched user has no interaction with the current user.
            else {
              //We still need to populate the searched user data.
              userSearched = value.docs[0].data();
              userSearched!['id'] = value.docs[0].id; //Setting the datas id.
            }
          }
          //We are finally outside the else this is not a self search segment.
        }
        //There is no user data for the searched value.
        else {
          //userSearched must be truned to null.
          userSearched = null;
          //Set noSearchedResults to true as there are no found results.
          noSearchedResults = true;
        }
      }),
      builder: (context, snapshot) {
        //Checks if the connectionState is compeleted.
        if (snapshot.connectionState == ConnectionState.done) {
          //StatefulBuilder allows us to set states from this builder even though this is not a class..
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            //Refresh the builder each time it is loaded.
            setState(() {});
            //We want to return the user that was searched, similar to how we returned the chats in AllChatsPage class.
            return Center(
              child: Column(
                //Columns child will only contains one ListTile, at a time.
                children: [
                  //We check if the userSearched is popluated.
                  userSearched != null
                      ?
                      //Return the list tile.
                      ListTile(
                          //On tap we want the user to be able to visit the searched users page.
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        OtheUserPage(
                                          id: userSearched![
                                              'id'], //Give the usered users id.
                                          name: userSearched![
                                              'name'], //Give the usered users name.
                                          isSentRequest:
                                              false, //We are not the sent request page, so false.
                                        )));
                          },
                          //Leading set to a profile icon to show that they are users.
                          leading: Icon(Icons.person,
                              color: hexStringToColor('471dbc')),
                          //Show the users username, as that is what is searched.
                          title: Text(
                            userSearched!['username'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ), //Similar style to the chats page.
                          subtitle: Text(userSearched![
                              'name']), //Subtitle needs to be the users name.
                          //Trailing will allow us to sent a request, cancel a request or see if we are friends.
                          trailing:
                              //Check if the users are friends first.
                              areFriends == true
                                  ? const Text(
                                      'Friends') //If they are show Friends text to the user.
                                  //If they are not friends check that the user has not sent a request to the user.
                                  : sentRequest == false
                                      //Add Friend button.
                                      ? TextButton(
                                          child: const Text('Add Friend'),
                                          //When pressed we access the database.
                                          onPressed: () async {
                                            //We get the current users data.
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(_auth
                                                    .getUid()) //Current user
                                                .update({
                                              "sent_requests":
                                                  FieldValue.arrayUnion(
                                                      [userSearched!['id']])
                                            }); //We update the current users sent_request array to contain the searched users id.
                                            //Need to update the searched users received_requests array.
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userSearched![
                                                    'id']) //The searched users id.
                                                .update({
                                              "received_requests":
                                                  FieldValue.arrayUnion(
                                                      [_auth.getUid()])
                                            }); //We update the searched users searched array to contain the current users id.
                                            //We have sent a request so we can change the setState of sentRequest to true.
                                            setState(() {
                                              sentRequest = true;
                                            });
                                          },
                                        )
                                      //Then we need to check if the current user has received a request from the searched user.
                                      : receivedRequest == true
                                          ? TextButton(
                                              onPressed:
                                                  () async {}, //We do not do anything if they have.
                                              child: const Text(
                                                'Received Request',
                                                style: TextStyle(
                                                    color: Colors
                                                        .red), //Need to show that the current user has received a request from the searched user.
                                              ))
                                          :
                                          //Otherwise the user has sent a request to the searched user.
                                          TextButton(
                                              child: const Text(
                                                'Request Sent',
                                                style: TextStyle(
                                                    color: Colors
                                                        .red), //Need to show this to the user.
                                              ),
                                              //When this button is pressed we can unsend the sent request.
                                              onPressed: () async {
                                                //Need to access the current users data, to remove the searched users id from sent_requests.
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(_auth
                                                        .getUid()) //Current user.
                                                    .update({
                                                  "sent_requests":
                                                      FieldValue.arrayRemove(
                                                          [userSearched!['id']])
                                                }); //Removing the searched users id from the current users sent request array.
                                                //Need to remove the current user from the searched users data.
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(userSearched!['id'])
                                                    .update({
                                                  "received_requests":
                                                      FieldValue.arrayRemove(
                                                          [_auth.getUid()])
                                                }); //Removing the current users id from the searched users received_requests array.
                                                //The sent request has no been removed so we can change the value back to false.
                                                setState(() {
                                                  sentRequest =
                                                      false; //SetState changing this value mean that the buttons will update when the value changes.
                                                });
                                              },
                                            ))
                      :
                      //If there is no data inside userSearched then we need to return the  no results text.
                      returnNoResults(),
                ],
              ),
            );
          });
        }
        //If the connection is not done we can return a CircularProgressIndicator while we wait for it be be compeleted.
        else {
          return Center(
            child: CircularProgressIndicator(
              color: hexStringToColor('471dbc'),
            ),
          ); //Same colour as the rest of the app.
        }
      },
    );
  }

//Build suggestions will show suggestions to the user of what user to search.
  @override
  Widget buildSuggestions(BuildContext context) {
    //We need to call this method as it populates the searchList.
    createSearchList();
    //Setting up the suggestions.
    final suggestions = query.isEmpty
        //Shows the recent users if the query is empty. This matches with other searches.
        ? recentUsers
        //If it is is not empty then we need to buidl the query.
        : userList.where((user) {
            //Takes the querys and builds a list.
            final userLower = user.toLowerCase();
            //Puts query to lower case.
            final queryLower = query.toLowerCase();
            //Trys to match the lower case query to the lowercase user list.
            return userLower.startsWith(queryLower);
          }).toList();
    //Returning the suggestions
    return buildSuggestionsSuccess(suggestions);
  }

  //If the user has tapped on a suggestion.
  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
        itemCount:
            suggestions.length, //Make the ListView as long as the suggestions.
        itemBuilder: (context, index) {
          //Build the suggestion items.
          final suggestion = suggestions[index];
          //Checks if the queryText is a substring of the suggestion, this allows us to highlight the query inside the text as it is typed.
          final queryText = suggestion.substring(0, query.length);
          //remainingText allows us to keep some of the text grey of the suggestion.
          final remainingText = suggestion.substring(query.length);

          return ListTile(
            onTap: () {
              //This changes to the query to the suggestion once it is clicked.
              query = suggestion;
              //We need to sho results
              showResults(context);
            },
            //For the leading we want to show the person icon to show that he searched values are users.
            leading: recentUsers.first ==
                    '' //But if the recentUsers first value contains an empty string, we want to show nothing.
                ? const Icon(
                    Icons.person,
                    color: Colors
                        .transparent, //Transparent so the users do not see it.
                  )
                : const Icon(Icons.person),
            // title: Text(suggestion),
            //This highlights the suggestion as its being typed.
            title: RichText(
              text: TextSpan(
                text: queryText,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ), //As the query is being typed the the blod will cover some of the suggestion text.
                children: [
                  TextSpan(
                    text: remainingText,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ), //The remaining text will stay grey.
                  ),
                ],
              ),
            ),
          );
        },
      );
}
