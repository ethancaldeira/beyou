import 'package:beyou/screens/profile_screen.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'other_users_page.dart';

//Class shows all the sent requests from the user.
class SentRequestPage extends StatefulWidget {
  const SentRequestPage({Key? key}) : super(key: key);

  @override
  _SentRequestPageState createState() => _SentRequestPageState();
}

class _SentRequestPageState extends State<SentRequestPage> {
  //Need auth as we are querying the database.
  final AuthService _auth = AuthService();
  //Need to store the friend requests from the user table.
  Map<String, dynamic>? sentRequest;
  //Need a list to store the data of those who have sent requests.
  List<Map<String, dynamic>?> sentData = [];
  //Need a bool to check if the user has sent no requests.
  bool isSentDataEmpty = true;
  //Need a bool to check if the information is still being loaded from the database.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //Need to check for the sent requests in the init state.
    findSentRequest();
  }

  void findSentRequest() async {
    //Sets the current user id to a local variable called myId.
    String myId = await _auth.getUid();

    //Set isLoading to true as we start to query the database.
    setState(() {
      isLoading = true;
    });

    //Querying to find the current users data, as we need to find their sent friends requests.
    await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId,
            isEqualTo: myId) //Querying the current users document.
        .get()
        .then((value) async {
      //Now we have the users data we need to check if they have sent friend requests.
      if (value.docs[0]["sent_requests"].toString() != '[]') {
        //If they have sent requests then we need to collect each user data for who the request was sent to individually.
        for (var x in value.docs[0]["sent_requests"])
        //Looping through each user who were sent a request from the current user by checking the sent_requests field.
        {
          sentRequest = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId,
                  isEqualTo:
                      x) //x is the user id of who received the current users sent request.
              .get()
              .then((value) async {
            //Now we are inside the user who was sent a request from the current user we must add their data to the sentData list.
            setState(() {
              //Add all the data into sentRequest.
              sentRequest = value.docs[0].data();
              //Add the field of id into sentRequest.
              sentRequest!['id'] = value.docs[0].id;
              //Add this current friends data into the sentData list.
              sentData.add(sentRequest);
            });
          });
        }
        //We are still in the if user has received a request statement, but we have finished adding the user data into our list.
        setState(() {
          //So we set isLoading to false as we have stopped loading the data.
          isLoading = false;
          //So we set isSentDataEmpty to false as we have have data on the users who were sent a request.
          isSentDataEmpty = false;
        });
      }
      //If the user has sent no requests we can stop loading.
      else {
        setState(() {
          isLoading = false;
          //Need to change to true as the current user has sent no requests.
          isSentDataEmpty = true;
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
          "Sent Friend Requests",
          style: TextStyle(color: hexStringToColor("471dbc")),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: hexStringToColor("471dbc"),
          onPressed: () {
            //Sends the user back to profile page and refreshes the page.
            Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ProfilePage()))
                .then((value) => setState(() => {}));
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: isLoading == true
          ? Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  color: hexStringToColor('471dbc'),
                ),
              ), //Returns a CircularProgressIndicator if we are still loading data from the database.
              //If we are done loading we need to check if the user has sent friend requests.
            )
          : isSentDataEmpty == false
              //If the user has sent request we need to show them to the user.
              //Using a ListView we can build the sent requests into ListTiles.
              ? ListView.builder(
                  itemCount: sentData
                      .length, //Length is the same length as the list that contains all the sent requests.
                  itemBuilder: (context, index) {
                    return ListTile(
                      //If the user taps on a request, they should be pushed to that users page.
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        OtheUserPage(
                                          id: sentData[index]![
                                              'id'], //Need the users id.
                                          name: sentData[index]![
                                              'name'], //Need the user name.
                                          isSentRequest:
                                              true, //Page is sent request page.
                                        )));
                      },
                      //Similar to the AllChatsPage we want the user to see the user who the request was sent to.
                      leading:
                          Icon(Icons.person, color: hexStringToColor('471dbc')),
                      title: Text(
                        sentData[index]!['name'], //Lead with users name
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(sentData[index]![
                          'username']), //Subtitle with the friends username, like the AllChatsPage class.
                      //Trailing we have a cancel request button.
                      trailing: IconButton(
                        //If the user presses the cancel button the request will be unsent.
                        onPressed: () async {
                          //Cancel request method is called and passed the id of the selected user.
                          cancelRequest(sentData[index]!['id']);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    );
                  })
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'You have no sent friends requests!', //Informs the user that they have not sent any requests.
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: hexStringToColor('471dbc'), fontSize: 32),
                    ),
                  ),
                ),
    );
  }

  //Method to cancel a request given a specific id.
  void cancelRequest(id) async {
    //Removing the new freinds id from both sent/recieved request lists in current users table.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .update({
      "sent_requests": FieldValue.arrayRemove([id])
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .update({
      "received_requests": FieldValue.arrayRemove([id])
    });

    //Removing the current users id from both sent/recieved request lists in new friends users table.
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      "received_requests": FieldValue.arrayRemove([_auth.getUid()])
    });
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      "sent_requests": FieldValue.arrayRemove([_auth.getUid()])
    });

    //Refreshing the page.
    setState(() {
      isLoading = true; //Needs to reload the data.
      sentData = []; //Empty the receivedData list.
      findSentRequest(); //Repopulate the receivedData.
    });
  }
}
