import 'package:beyou/models/AppUsers.dart';
import 'package:beyou/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Code used from:
//AuthService as a Class provides methods to get data from the firebase collecctions.
class AuthService {
  AppUsers? _userFromFirebaseUser(User? myUser) {
    return myUser != null ? AppUsers(uid: myUser.uid) : null;
  }

  //Need a method to authenticate a new user account.
  Future authNewUser(String name, String username, String email,
      String password, String companion)

  //We take parameters for the email and the password.
  //We also need the username and name of the urse.
  async {
    //We then need to authenticate the new user.
    UserCredential authResult = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: email,
            password:
                password); //Creates the new user auth from FirebaseAuth using the email and password.

    //Sets the current user to the authResult.user.
    User? newUser = authResult.user;
    //Now we need to add the user data to the 'users' collection in firebase.
    await DatabaseService(
            uid: newUser!
                .uid) //Uses the new users user id as the document field id.
        .createUserData(username, name, email,
            companion); //Gives the createUserData method the username, name and email.
    return _userFromFirebaseUser(newUser); //Returns the new user.
  }

  //Method used to get the unique user id.
  getUid() {
    User? myUser = FirebaseAuth.instance.currentUser;
    var uid = myUser!.uid;
    return uid; //Returns the unique id from the current user.
  }
}
