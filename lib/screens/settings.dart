import 'package:beyou/screens/profile_screen.dart';
import 'package:beyou/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';

//This is class is for the settings page.
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //We need AuthService as we are going to query the database.
  final AuthService _auth = AuthService();
  //We need two TextEditingControllers to allow the user to change their password.
  final TextEditingController password = TextEditingController();
  //This second TextEditingController allows us to ensure that the user has entered the correct password twice.
  final TextEditingController secondPassword = TextEditingController();
  //We now need to get the email from the database, and add it to a TextEditingController so it can be edited.
  late TextEditingController email;
  //Same for the username, this is taken from the database.
  late TextEditingController username;
  //Same for the name, this is taken from the database.
  late TextEditingController name;
  //Same for the companion name, this is taken from the database.
  late TextEditingController companion;

  //Need bool values to check if there is no errors with the new email.
  bool emailErorr = true;
  //Need bool values to check if there is no errors with the new password.
  bool passwordErorr = true;
  //Need bool values to check if there is no errors with the new username.
  bool usernameErorr = true;
  //Need a bool to tell use when the user data has been updated.
  bool updatedUserData = false;
  //Need a bool to tell us when the users entries have been updated.
  bool updatedEntriesData = false;
  //Need a bool to indicate when the process has finished.
  bool completedProcress = false;
  //Need a string to store the userId.
  late String userId;
  //Need a string to store the current username.
  late String currentUsername;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same style app bar as the other pages.
      appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(color: hexStringToColor("471dbc")),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor("471dbc"),
            onPressed: () {
              Navigator.pop(
                  context); //Sends them back to the profile page, no need to refresh.
            },
          ),
          elevation: 0),
      backgroundColor: Colors.white,
      //Need a FutureBuilder to allow us to query the database.
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId,
                isEqualTo: _auth.getUid()) //Finds the current users data/.
            .get(),
        builder: (_, snapshot) {
          //If there is an error to when querying we need to show that to the user.
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          //If there is data we need to find that data.
          if (snapshot.hasData) {
            //No need to check if the data is empty like other pages, this is because the user will have these values, as -
            //it is set up when they create their accounts.

            //Save the data to a variable called docs.
            var docs = snapshot.data?.docs;
            //Now we take the email, and save it as the TextEditingController text.
            email = TextEditingController(text: docs![0]['email'].toString());
            //Now we take the username, and save it as the TextEditingController text.
            username =
                TextEditingController(text: docs[0]['username'].toString());
            //Now we take the name, and save it as the TextEditingController text.
            name = TextEditingController(text: docs[0]['name'].toString());
            //Now we take the companion name, and save it as the TextEditingController text.
            companion = TextEditingController(
                text: docs[0]['companion_name'].toString());
            //We need the users id so we can take that from the document.
            userId = docs[0].reference.id.toString();
            currentUsername = docs[0]['username'].toString();
            //Then we can return the input fields.
            return Padding(
              padding:
                  const EdgeInsets.all(12.0), //Padding stops an overflow error.
              child: Column(
                //Column used to hold each input field.
                children: <Widget>[
                  //This row holds the Enter new email text.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enter new email:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hexStringToColor('471dbc')))
                    ],
                  ),
                  const SizedBox(height: 15), //Gap from text to input field.
                  //Input field for the email.
                  TextFormField(
                      controller: email,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      cursorColor: hexStringToColor(
                          '471dbc'), //Same cursor as other input fields.
                      decoration: const InputDecoration.collapsed(
                          hintText:
                              'New Email')), //New email shown as the hint text.
                  const SizedBox(
                      height: 30), //Gap from input field to next text.
                  //This row holds the Change your username text.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Change your username:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hexStringToColor('471dbc')))
                    ],
                  ),
                  const SizedBox(
                      height: 15), //Gap from text to the next input field.
                  //Input for the users new username.
                  TextFormField(
                      controller: username,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      cursorColor: hexStringToColor(
                          '471dbc'), //Same cursor as other input fields.,
                      decoration: const InputDecoration.collapsed(
                          hintText:
                              'New username')), //New username shown as the hint text.
                  const SizedBox(
                      height: 30), //Gap from input field to next text.
                  //This row holds the Enter Name text.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enter Name:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hexStringToColor('471dbc')))
                    ],
                  ),
                  const SizedBox(height: 15), //Gap from field to input.
                  //Input for the users new name.
                  TextFormField(
                      controller: name,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      cursorColor: hexStringToColor(
                          '471dbc'), //Same cursor as other input fields.
                      decoration: const InputDecoration.collapsed(
                          hintText:
                              'New Name')), //New name shown as the hint text.
                  const SizedBox(
                      height: 30), //Gap from input field to next text.

                  //This row holds the Enter Comapnion name text.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enter New Companion Name:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hexStringToColor('471dbc')))
                    ],
                  ),
                  const SizedBox(height: 15), //Gap from field to input.
                  //Input for the users new name.
                  TextFormField(
                      controller: companion,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      cursorColor: hexStringToColor(
                          '471dbc'), //Same cursor as other input fields.
                      decoration: const InputDecoration.collapsed(
                          hintText:
                              'New Name')), //New name shown as the hint text.
                  const SizedBox(
                      height: 30), //Gap from the input field to the text.
                  //This is the text prompt for the new password.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create new Password:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: hexStringToColor('471dbc')))
                    ],
                  ),
                  const SizedBox(
                      height: 15), //Gap from the text to the input field.
                  //Input field for the new password.
                  TextFormField(
                      controller: password,
                      keyboardType: TextInputType.multiline,
                      //As the field its a password, user should not see it.
                      //Helped from: https://stackoverflow.com/questions/49125064/how-to-show-hide-password-in-textformfield
                      obscureText:
                          true, //As the field its a password, user should not see it.
                      autocorrect:
                          false, //We do not need autocorrect as it is a password.
                      maxLines: 1,
                      cursorColor: hexStringToColor(
                          '471dbc'), //Same cursor as other input fields.
                      decoration: const InputDecoration.collapsed(
                          hintText: 'New Password')), //Hint for new password.
                  const SizedBox(
                      height:
                          15), //Gap from the first password input to the next password input.
                  //Input for the user to re-enter their password.
                  TextFormField(
                      controller: secondPassword,
                      keyboardType: TextInputType.multiline,
                      obscureText:
                          true, //As the field its a password, user should not see it.
                      autocorrect:
                          false, //We do not need autocorrect as it is a password.
                      maxLines: 1,
                      cursorColor: hexStringToColor(
                          '471dbc'), //Same cursor as other input fields.
                      decoration: const InputDecoration.collapsed(
                          hintText:
                              'Re-enter new Password')), //Hint to re-enter the new password.
                ],
              ),
            );
          }
          //While there is no data in the snapshot we need to show a CircularProgressIndicator to the user.
          return Center(
              child: CircularProgressIndicator(
            color: hexStringToColor('471dbc'),
          ));
        },
      ),
      //Save button uploads the
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.check,
            semanticLabel: 'Save',
          ), //Save icon to show that the button saves the data.
          backgroundColor: hexStringToColor(
              '2e3887'), //Same colour as the other buttons within the app.
          onPressed: () async {
            //Need to check that the new username is free.
            await FirebaseFirestore.instance
                .collection("users")
                .where('username', isEqualTo: username.text)
                .get()
                .then((value) {
              //Checking it is free.
              if (value.docs.isEmpty) {
                setState(() {
                  usernameErorr = false;
                });
                //Checking it is the same as the current text
              } else if (currentUsername == username.text) {
                setState(() {
                  usernameErorr = false;
                });
                //Setting the erorr to true as the name is taken.
              } else {
                setState(() {
                  usernameErorr = true;
                  usernameTaken(context);
                });
              }
            });
            //We need to run some checks before we can save the data.
            if (password.text != secondPassword.text)
            //Checking for matching passwords. They can also both be blank
            {
              passwordMatchErrorText(
                  context); //Show the match error promot if they do not match.
            } else if (email.text == '' ||
                username.text == '' ||
                name.text == '' ||
                companion.text == '')
            //Otherwise we need to check that all the fields have values.
            {
              //If they do not we show the noText prompt to the user.
              noText(context);
            } else {
              //Uses the update email method to update the users email.
              updateEmail(email);
              //Checks if both passwords are not empty, because if they are both empty they will match.
              if (password.text != '' && secondPassword.text != '') {
                //If they are not empty then we can update the password.
                updatePassword(password);
              } else {
                //else they have not entred a new password so we do not need to do anything.
                //We want update the passwords, so there is no error.
                //This allows users to the ability not to enter a new password.
                setState(() {
                  passwordErorr = false;
                });
              }
            }
            //If theere are no errors then we can update some data.
            if (emailErorr == false &&
                passwordErorr == false &&
                usernameErorr == false) {
              //Create the data we want to update.
              Map<String, dynamic> data = {
                "email": email.text,
                "username": username.text,
                "name": name.text,
              };
              //Connect to the database.
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update(data); //Update the specific data fields.
              //Then set the updatedUserData to true as we have update their data.
              setState(() {
                updateUserEntries();
              });
            }
          }),
    );
  }

  //Method to update the users password.
  void updatePassword(password) async {
    await FirebaseAuth.instance.currentUser!
        .updatePassword(
            password.text) //We use the FirebaseAuth build in update method.
        .then(((value) {
      //If it runs we need to say there was no error for the passwords.
      setState(() {
        passwordErorr = false;
      });
    })).onError((passworderror, stackTrace) {
      //If there is an error we need to show that to the user.
      //The setState() above will not run if an error is found.
      //Format the error so that the user can see it.
      //Code adapted from: https://stackoverflow.com/questions/70609591/remove-text-between-parentheses-in-dart-flutter
      String formatError =
          passworderror.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      setState(() {
        passwordErorr = true;
      });
      //Show the prompt to the user that there is a password error.
      passwordErrorText(context, formatError);
    });
  }

  //Method to update the email
  void updateEmail(email) async {
    await FirebaseAuth.instance.currentUser!
        .updateEmail(
            email.text) //We use the FirebaseAuth build in update method.
        .then(((value) {
      //If it runs we need to say there was no error for the emails.
      setState(() {
        emailErorr = false;
      });
    })).onError((error, stackTrace) {
      //If there is an error we need to show that to the user.
      //The setState() above will not run if an error is found.
      //Format the error so that the user can see it.
      String formatError = error.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      setState(() {
        emailErorr = true;
      });
      //Show the prompt to the user that there is a email error.
      emailErrorText(context, formatError);
    });
  }

  //Need a method to update the entries that the user has posted.
  void updateUserEntries() async {
    await FirebaseFirestore.instance
        .collection('entries')
        .where('owner_id',
            isEqualTo: _auth
                .getUid()) //We use the id of the user instead of the username.
        .orderBy("date", descending: true)
        .get()
        .then((value) async {
      //Check that the user has entries.
      if (value.docs.toString() != '[]') {
        //We set the length of the entries.
        var len = value.docs.length;
        //We loop through the entries and update the username.
        for (int i = 0; i < len; i++) {
          await FirebaseFirestore.instance
              .collection('entries')
              .doc(value.docs[i].id)
              .update({
            'owner_username': username.text
          }); //Update the usernames of each entry.
        }
        //There would be an issue where the first and last element are not updated.
        //In order to fix this we check if the length is greater than 1.
        //If it is not we do not need to update the first and last elements.
        if (len > 1) {
          await FirebaseFirestore.instance
              .collection('entries')
              .doc(value.docs[len - len]
                  .id) //We go to the first document of the entries.
              .update({
            'owner_username': username.text
          }); //Update the username within that document.
          await FirebaseFirestore.instance
              .collection('entries')
              .doc(value.docs[len - 1]
                  .id) //We go to the last document of the entries.
              .update({
            'owner_username': username.text
          }); //Update the username within that document.
        }
        //We have now finished we need to update the exercises.
        updateExercises();
      } else {
        //There are no posts so we do not do anything.
        //We have now finished we need to update the exercises.
        updateExercises();
      }
    });
  }

  //We also need to update the exercises done by the user.
  void updateExercises() async {
    //Query the exercise collection within firebase.
    await FirebaseFirestore.instance
        .collection('exercises')
        .where('owner_id',
            isEqualTo:
                _auth.getUid()) //Finding exercises done by the current user.
        .get()
        .then((value) async {
      //Check that the exercises are not empty.
      if (value.docs.toString() != '[]') {
        //We set the length of the exercises.
        var len = value.docs.length;
        //We loop through the exercises and update the username.
        for (int i = 0; i < len; i++) {
          await FirebaseFirestore.instance
              .collection('exercises')
              .doc(value.docs[i].id)
              .update({
            'owner_username': username.text
          }); //Update the usernames of each exercise.
        }
        //Same problem as with the updating the entries.
        if (len > 1) {
          await FirebaseFirestore.instance
              .collection('exercises')
              .doc(value.docs[len - len]
                  .id) //We go to the first document of the exercises.
              .update({'owner_username': username.text}); //Update the username.
          await FirebaseFirestore.instance
              .collection('exercises')
              .doc(value.docs[len - 1]
                  .id) //We go to the last document of the exercises.
              .update({'owner_username': username.text}); //Update the username.
        }
        navigate(context);
      } else {
        //Even if there are no exercises to update we have finished the process.
        navigate(context);
      }
    });
  }

  //We need to navigate the user back to the ProfilePage and refresh the page for the updates to be successful.
  navigate(context) {
    //We show a success prompt to the user.
    successPrompt(context);
    //We navigate the user back to the profile page, after waiting to seconds.
    Future.delayed(const Duration(seconds: 2), () {
      //This allows the updates to happen, and for the user to read the success prompt.
      //Then we push the user to the profile page.
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfilePage())).then((value) => setState(() {}));
    });
  }
}

//Method shows that success prompt to the user.
successPrompt(context) {
  showDialog(
      barrierDismissible:
          false, //We do not want the user to dismiss this prompt.
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Text("Successful"),
          content: Text(
            "\nAll the data has been successfully updated!",
          ), //Successful text shown to the user.
        );
      });
}

//Below is a collection of prompt shown to the user based on errors.
//This method shows the missing text prompt to the user.
noText(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Text("Missing Text"),
          content: Text(
            "Please fill in the all sections to update your data!",
          ), //Correct message displayed.
        );
      });
}

//This method shows the missing text prompt to the user.
usernameTaken(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Text("That Username is taken"),
          content: Text(
            "Please try another username",
          ), //Correct message displayed.
        );
      });
}

//This method shows the password match error  prompt to the user.
passwordMatchErrorText(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Text("Passwords Do Not Match"),
          content: Text(
            "\nThe new passwords entered do not mactch. Please try agian.",
          ), //Correct message displayed.
        );
      });
}

//This method shows the password error to the user.
passwordErrorText(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Enter a Vaild Password"),
          content: Text(
            "\nThere was an error with the new password, please try agian.\n\nHint:${error.toString()}",
            //Shows the hint from the error that is returned from FirebaseAuth.
          ), //Correct message displayed.
        );
      });
}

//This method shows the email error to the user.
emailErrorText(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Enter a Vaild Email"),
          content: Text(
            "\nThere was an error with the email, please try agian.\n\nHint:${error.toString()}",
            //Shows the hint from the error that is returned from FirebaseAuth.
          ), //Correct message displayed.
        );
      });
}
