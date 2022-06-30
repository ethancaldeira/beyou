import 'package:beyou/screens/other_users_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth.dart';

//Class shows the user a list of their friends and allows them to remove a friend.
class FriendsListPage extends StatefulWidget {
  const FriendsListPage({Key? key}) : super(key: key);

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  //We need the current user id to query the database.
  final AuthService _auth = AuthService();
  //We need to store friends data, for when we iterate and query at the same time.
  Map<String, dynamic>? friendData;
  //We need to add the friendData into a list so that we can store all the friends data.
  List<Map<String, dynamic>?> allFriends = [];
  //User might not have friends so we need to show a prompt if they do not.
  bool noFriends = true;
  //We need an isLoading while we wait for the values from the database.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //Main method that collects all the friends data, so is needed in the initState.
    findFriends();
  }

  //Method to find the users friend and their data.
  void findFriends() async {
    //Need the current users id to query the database.
    String myId = _auth.getUid();

    //Set isLoading to true as we start to query the database.
    setState(() {
      isLoading = true;
    });
    //Querying to find the current users data, as we need to find their friends.
    await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId,
            isEqualTo: myId) //Querying the current users document.
        .get()
        .then((value) async {
      //Now we have the users data we need to check if they have friends.
      if (value.docs[0]["friends"].toString() != '[]') {
        //If they do have friends then we need to collect each friends data individually.
        for (var x in value.docs[0]["friends"])
        //Looping through each friend inside the friends field.
        {
          friendData = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, isEqualTo: x) //x is the friends id.
              .get()
              .then((value) async {
            //Now we are inside the friends we must add their data to the allFriends list.
            setState(() {
              //Add all the data into friendData.
              friendData = value.docs[0].data();
              //Add the field of id into friendData.
              friendData!['id'] = value.docs[0].id;
              //Add this current friends data into the allFriends list.
              allFriends.add(friendData);
            });
          });
        }
        //We are still in the if user has friends statement, but we have finished adding friends data into our list.
        setState(() {
          //So we set isLoading to false as we have stopped loading the data.
          isLoading = false;
          //So we set noFriends to false as we have have data on friends so the user has friends.
          noFriends = false;
        });
      }
      //If the user has no friends we can stop loading.
      else {
        setState(() {
          isLoading = false;
          //Need to change to true as the user has no friends.
          noFriends = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same AppBar as other pages inside the app. Keeps design constant.
      appBar: AppBar(
        title: Text(
          "Friends List",
          style: TextStyle(color: hexStringToColor("471dbc")),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: hexStringToColor("471dbc"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      //Checks if isLoading is true, waiting to see if the query from the database is done.
      body: isLoading == true
          ? Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  color: hexStringToColor('471dbc'),
                ),
              ),
            ) //Returns a CircularProgressIndicator if we are still loading data from the database.
          //If we are done loading we need to check if the user has friends.
          : noFriends == false
              ? ListView.builder(
                  //If the user has friends we need to show them to the user.
                  //Using a ListView we can build the friends into ListTiles.
                  itemCount: allFriends
                      .length, //Length is the same length as the list that contains all the friends
                  itemBuilder: (context, index) {
                    return ListTile(
                      //If the user taps on a friend, they should be pushed to that friends page.
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        OtheUserPage(
                                          id: allFriends[index]![
                                              'id'], //Need the friends id.
                                          name: allFriends[index]![
                                              'name'], //Need the friends name.
                                          isSentRequest:
                                              false, //Page is not sent request page.
                                        )));
                      },
                      //Similar to the AllChatsPage we want the user to see the friends.
                      leading:
                          Icon(Icons.person, color: hexStringToColor('471dbc')),
                      title: Text(
                        allFriends[index]![
                            'name'], //Lead with the friends name.
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ), //Leading with a profile icon to indicate to the user that these are their friends.
                      subtitle: Text(allFriends[index]![
                          'username']), //Subtitle with the friends username, like the AllChatsPage class.
                      //Trailing we have a remove friends button.
                      trailing: IconButton(
                        onPressed: () async {
                          //If the user presses this button they will be asked if they want to remove their friend from their list.

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                    //Using the friends name in the dialog to the user.
                                    //Helps to make the app feel more interactive, as it is not just a static prompt.
                                    title: Text(
                                        "Remove ${allFriends[index]!['name']}?"),
                                    content: Text(
                                      "Are you sure you want to remove your friend ${allFriends[index]!['name']}?",
                                    ),
                                    //Buttons for either yes or no.
                                    actions: [
                                      CupertinoDialogAction(
                                          child: const Text(
                                            "Yes",
                                          ),
                                          //If they select yes.
                                          onPressed: () {
                                            //Remove friend method is called and passed the id of the selected friend.
                                            removeFriend(
                                                allFriends[index]!['id']);
                                            //The dialog is then popped off the screen as the friend is removed.
                                            Navigator.of(context).pop();
                                          }),
                                      //If the users select no.
                                      CupertinoDialogAction(
                                          child: const Text("No"),
                                          onPressed: () {
                                            //The dialog is popped off the screen and the user is not removed.
                                            Navigator.of(context).pop();
                                          })
                                    ]);
                              });
                        },
                        icon: const Icon(Icons
                            .close), //Need to use the close icon to indicate to the user that they can remove their friend.
                      ),
                    );
                  })
              //If the user has no friend, prompt them to add friends.
              //Same text style as AllChatsPage class.
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Add Friends to see a list of them!', //Prompts the user to add friends as they have non currently.
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: hexStringToColor('471dbc'), fontSize: 32),
                    ),
                  ),
                ),
    );
  }

  void removeFriend(id) async {
    //Removing the id of the user from both friend lists.
    //Current users friend list, removing the friend.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .update({
      "friends": FieldValue.arrayRemove([id])
    });

    //Removing the current user from the friends, friend list.
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      "friends": FieldValue.arrayRemove([_auth.getUid()])
    });

    //Now we need to reload the page
    setState(() {
      //Set isLoading to true.
      isLoading = true;
      //Empty the allFriends list.
      allFriends = [];
      //Populate all friends list again, essentially reloading the page.
      findFriends();
    });
  }
}
