import 'dart:convert';

import 'package:beyou/screens/sent_requests.dart';
import 'package:beyou/services/auth.dart';
import 'package:beyou/utils/character_controller.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../utils/check_time.dart';
import '../widgets/entry_preview.dart';

//Page used to to view another users profile.
class OtheUserPage extends StatefulWidget {
  final String id; //This is the other users id.
  final String name; //This is the other users name.
  final bool isSentRequest;

  const OtheUserPage(
      {Key? key,
      required this.id,
      required this.name,
      required this.isSentRequest})
      : super(key: key);

  @override
  _OtheUserPageState createState() => _OtheUserPageState();
}

class _OtheUserPageState extends State<OtheUserPage> {
  final AuthService _auth = AuthService();

  //All the below values are updated in the initState
  //Set the other users activity to zero.
  String activity = '0';
  //Set is active to false.
  bool isActive = false;
  //Bool value to check if the users are friends.
  bool areFriends = false;
  //Sets their username to blank.
  String username = '';
  //Need these bool values so that the user can make friends with the user.
  bool sentRequest = false;
  bool recievedRequest = false;

  @override
  void initState() {
    super.initState();
    checkFriendship(); //Need to check if the two users are friends. To keep the posts private if they are not friends.
    activityCheck(); //Check the other users activity, when they were last online or if they are online now.
    setUsername(); //Find the other users username from the database.
    checkTimeLimit(
        context); //Check that the current user has not surpassed their time limit.
  }

  //Mehtod checks when the user was last active.
  void activityCheck() async {
    //Querying the user being viewed.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget
            .id) //Using the correct id that is given as a parameter to this class.
        .get()
        .then((value) {
      //Create a variable to store the other users data.
      var data = value.data();

      //Checks if the user is currently offline.
      if (data!['status'] == 'Offline') {
        //If they are offline we need to find out when last they were online.
        var lastLoggedOn = data['log_off_time'].toDate();
        //Calculate the difference between right now and when the other user was last online in minutes.
        int diffMins = DateTime.now().difference(lastLoggedOn).inMinutes;

        //Calculate the difference between right now and when the other user was last online in hours.
        int diffHours = DateTime.now().difference(lastLoggedOn).inHours;

        //If the minutes are greater than 2 hours.
        if (diffMins > 120) {
          //We want to check if the difference in hours is greater than 24.
          if (diffHours > 24) {
            //If diffHours is greater than 24, we need to return the difference in days.
            setState(() {
              activity =
                  '${DateTime.now().difference(lastLoggedOn).inDays.toString()} days';
              //Sets activity to the difference between right now and when the other user was last online in days.
            });
          } else {
            //Else we can return the difference in hours.
            setState(() {
              activity =
                  '${DateTime.now().difference(lastLoggedOn).inHours.toString()} hours';
              //Sets activity to the difference between right now and when the other user was last online in hours.
            });
          }
        } else {
          //If diffMin is less then 120 or 2 hours we can show the activity in minutes.
          setState(() {
            activity =
                '${DateTime.now().difference(lastLoggedOn).inMinutes.toString()} mins';
            //Sets activity to the difference between right now and when the other user was last online in minutes.
          });
        }
      }
      //If the user is not 'Offline', they are online.
      else {
        setState(() {
          isActive = true; //So set isActive to true.
        });
      }
    });
  }

  //Method to get the other users username.
  void setUsername() async {
    //Query the other users data.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get()
        .then((value) {
      //Save the data to a variable.
      var data = value.data();
      //Set the users username to what is in the database.
      setState(() {
        username = data!['username'];
      });
    });
  }

  //Allows users to send friend requests.
  void sendFriendRequeset() async {
    //Adds the other users id to the sent_request array inside the current users data.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .update({
      "sent_requests": FieldValue.arrayUnion([widget.id])
    });
    //Adds the current users id to the recieved request array inside the other users data.
    await FirebaseFirestore.instance.collection('users').doc(widget.id).update({
      "received_requests": FieldValue.arrayUnion([_auth.getUid()])
    });
  }

  //Allows users to unsend a friend requeset, uses the same code as the send request method but it removes the id from the array -
  //instead of adding it.
  void unSendFriendRequeset() async {
    //Removes the other users id from the sent_request array inside the current users data.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .update({
      "sent_requests": FieldValue.arrayRemove([widget.id])
    });
    //Removes the current users id from the recieved request array inside the other users data.
    await FirebaseFirestore.instance.collection('users').doc(widget.id).update({
      "received_requests": FieldValue.arrayRemove([_auth.getUid()])
    });
  }

  //To keep accounts private we need to check if the current user and the other users are friends.
  void checkFriendship() {
    //Check current users data.
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .get()
        .then((value) {
      //Save the current users data into a variable.
      var userData = value.data();
      //Check if the current user friends contain the user id of the page we are viewing.
      if (userData!['friends'].contains(widget.id)) {
        print('contians');
        //If it does the two users are friends.
        setState(() {
          areFriends = true; //So are friends can be true.
        });
      }
      //If the user is not friends with other user they may have recieved a request.
      else if (userData['received_requests'].contains(widget.id)) {
        //If it does the two users are friends.
        setState(() {
          areFriends = false;
          recievedRequest = true; //So are friends can be true.
        });
      }
      //If the user is has not recieved a request with other user they may have sent a request.
      else if (userData['sent_requests'].contains(widget.id)) {
        //If it does the two users are friends.
        setState(() {
          areFriends = false;
          sentRequest = true; //So are friends can be true.
        });
      }
      //If they other users id is not inside the current users friend list, they are not friends.
      else {
        setState(() {
          areFriends = false; //So are friends is false.
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        //Same style app bar as other pages.
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            actions: [
              //Checks if the users are friends.
              areFriends == true
                  ? TextButton(
                      onPressed:
                          () async {}, //We do not want to do anything with this one
                      child: Text(
                        'Friends',
                        style: TextStyle(color: hexStringToColor('471dbc')),
                      )) //If they are show the text Friends in the app bar, button used so that the text is constant with the other texts.
                  //If the users are not friends we need to check if the current user has sent a request.
                  : sentRequest == false
                      ? TextButton(
                          onPressed: () async {
                            sendFriendRequeset(); //Send request on button click.
                            setState(() {
                              sentRequest = true; //Set sent request to true.
                            });
                          },
                          child: const Text(
                              'Add Friend')) //Add friend as the text for the button.
                      //Checks if the current user has recieved a request from the other user.
                      : recievedRequest == true
                          ? TextButton(
                              onPressed: () async {
                                //Prompt for the user to accept the other user as a friend?
                              }, //We do not want the user to do anything, just indicates that the user has sent a request.
                              child: const Text(
                                'Received Request',
                                style: TextStyle(
                                    color: Colors
                                        .red), //Received Request as the text we use to show the user.
                              ))
                          :
                          //If the user has not recieved a request then they must have sent one.
                          TextButton(
                              onPressed: () async {
                                unSendFriendRequeset(); //Allows users to unsed the friend request.
                                setState(() {
                                  sentRequest = false;
                                });
                              },
                              child: const Text(
                                'Request Sent',
                                style: TextStyle(color: Colors.red),
                              )) //Shows request sent to the user.
            ],
            //Back button for the user send them back to the page they have come from.
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: hexStringToColor('471dbc'),
              ),
              onPressed: () {
                //We need to check if the user is from the sent request page.
                if (widget.isSentRequest == true) {
                  //If they are we need to refresh that page when we send them back.
                  //User will be able to unsend requests on this page so this is important to refresh the SentRequestPage.
                  Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SentRequestPage()))
                      .then((value) => setState(() => {}));
                }
                //If they are not from the sent request page, they can just be sent back to the previous page.
                else {
                  Navigator.pop(context);
                }
              },
            )),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            //Show the current user, the other users name and their username.
            Padding(
                padding: const EdgeInsets.only(left: 12, top: 10, bottom: 5),
                child: Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 32,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 12, top: 5),
                child: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                )),
            //If the two users are friends then the current user should see their page.
            areFriends == true
                ? Center(
                    //FutureBuilder as we are going to find the state of the other users companion.
                    child: FutureBuilder(
                        future: calculateState(widget
                            .id), //Instead of querying the database we use the calculate state method, and add the other users id.
                        builder: (context, snapshot) {
                          //If there is an error in querying the database this must be shown to the user.
                          if (snapshot.hasError) {
                            return Text('Error = ${snapshot.error}');
                          }
                          if (snapshot.hasData) {
                            //Returns a list that we cast to a string.
                            var value = snapshot.data.toString();
                            //We need to jsonDecode the string so we can make it back into a list.
                            var listValue = jsonDecode(value);
                            //Creates a list from the string, and we are instrested in the first value of the list.
                            var state = listValue[0];
                            //Returns the other users companion.
                            return Column(
                              children: [
                                SizedBox(
                                    height: 300,
                                    width: 400,
                                    child: RiveAnimation.asset(
                                        "assets/new_file.riv",
                                        controllers: [
                                          SimpleAnimation(
                                              state), //Sets thier animation to the state from the list.
                                        ])),
                              ],
                            );
                          }
                          //If the calculateState does not return data, we need to show the indicator.
                          //This will only happen as we wait for the data to be returned.
                          else {
                            return SizedBox(
                              height: 410,
                              width: 400,
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: hexStringToColor('471dbc'))),
                              ),
                            );
                          }
                        }))
                //If the users are not friends that needs to be made clear.
                : Padding(
                    padding: const EdgeInsets.only(top: 250.0, bottom: 250),
                    child: SizedBox(
                      child: Column(children: const [
                        Icon(Icons
                            .lock), //lock icon shows that the user data not able to be seen if you are not friends
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                              'This User Is Not Your Friend'), //Message informing the user about this.
                        )
                      ]),
                    ),
                  ),
            const SizedBox(
              height: 15,
            ), //Gap between the character and the activity message.
            //Checks if they are firends
            areFriends == true
                //if they are we need to check if the other user is not active.
                ? isActive == false
                    //If they are not active, we show when last they were active by using the activity variable, which is updated in the initState.
                    ? Center(child: Text('Online $activity ago'))
                    //If they are active we need to show that.
                    : const Text(
                        '🟢 Online',
                        style: TextStyle(color: Colors.green),
                      ) //Shows that the user is active in green.
                : Container(), //If the users are not friends then the current user cannot see when last the other user was active.
            const SizedBox(height: 30), //Used for a gap.
            //Checks if the users are friends.
            areFriends == true
                //if they are we can show the current user their friends posts.
                ? Expanded(
                    child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('entries')
                          .where('owner_id',
                              isEqualTo: widget
                                  .id) //Query the posts with the friends id.
                          .orderBy("date",
                              descending: true) //Order them by date.
                          .get(),
                      builder: (_, snapshot) {
                        //If there is an error this needs to be shown to the user.
                        if (snapshot.hasError) {
                          return Text('Error = ${snapshot.error}');
                        }
                        //If there is data we can extract it.
                        if (snapshot.hasData) {
                          //Save the data into a variable called friendPosts
                          var friendPosts = snapshot.data?.docs;

                          //Friend may not have any posts.
                          if (friendPosts.toString() == '[]') {
                            return const Center(
                                child: Text(
                                    'No posts here!')); //Tell the current user their are no posts from their friend.
                          } else {
                            //Create a length of the friendPosts which will be used in the ListView.
                            var len = friendPosts?.length;

                            return MediaQuery(
                              data: MediaQuery.of(context).removePadding(
                                  removeTop:
                                      true), //Removes the auto padding that comes with the ListView.
                              child: ListView(
                                  children: List.generate(
                                      len!,
                                      (index) => friendEntryPreview(
                                          friendPosts![index].id,
                                          context,
                                          friendPosts[index]['owner_id'],
                                          friendPosts[index]['title'],
                                          friendPosts[index]['date'],
                                          index,
                                          friendPosts[index]['tag'],
                                          widget.name,
                                          false))), //Using the custom friend entry previews, we can return the posts to the user.
                            );
                          }
                        }
                        //While we load the friends posts we need to show the CircularProgressIndicator.
                        return Center(
                            child: CircularProgressIndicator(
                          color: hexStringToColor('471dbc'),
                        ));
                      },
                    ),
                  )
                //If the two users are not friends we return an empty container.
                : Container()
          ],
        ));
  }
}
