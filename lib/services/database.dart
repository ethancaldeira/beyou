import 'package:cloud_firestore/cloud_firestore.dart';

//For this class there are methods that are used to add to the database or retrieve data from database.
class DatabaseService {
  //We need the users unique id for any of the querys to work.
  final String uid;
  //Hence the required parameter.
  DatabaseService({required this.uid});
  //First method is to create the user data. This is used in the authNewUser method inside the AuthService class.
  Future createUserData(
      String username, String name, String email, String companion) async {
    //We set the fields that are needed for the user account.
    return await FirebaseFirestore.instance.collection("users").doc(uid).set({
      'username': username, //Parameter value.
      'name': name, //Parameter value.
      'email': email, //Parameter value.
      'friends': [], //No friends yet.
      'sent_requests': [], //No requests sent yet.
      'received_requests': [], //No requests received yet.
      'companion_name': companion, //Name for the users companion.
      'log_on_time': '' //User has not logged on yet so we leave it blank.
    });
  }

  //Method needed to get the current users username.
  Future<String> retreiveUsername() async {
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    //Return the username field from the document.
    return document['username'];
  }

  //Method needed to get the friend lift of the current users friends.
  Future<List> retreiveFriends() async {
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    //Return the friends array from the document.
    return document['friends'];
  }

  //Method needed to get all the data from the current user.
  getUserData() async {
    DocumentSnapshot user =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    //Return the user data for the current user from the collection 'users' inside firebase.
    return user.data();
  }

  //Method creates a new chat for the chats collection.
  addChat(chatData, chatId) {
    FirebaseFirestore.instance.collection("chats").doc(chatId).set(chatData);
  }

  //Method creates a message to send inside the chat, it is done by adding the message text to the -
  //subcollection of chats which is messages.
  addMessage(String chatId, messageData) async {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add(messageData);
  }

  //Method which lets us checks the current users chats.
  getUserChats(String itIsMyName) {
    return FirebaseFirestore.instance
        .collection("chats")
        .where('users', arrayContains: itIsMyName)
        .get();
  }
}
