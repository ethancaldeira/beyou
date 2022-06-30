import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beyou/widgets/input_buttons_widget.dart';
import 'package:beyou/screens/home_screen.dart';
import 'package:beyou/screens/reset_password_screen.dart';
import 'package:beyou/screens/signup_screen.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';

//Page the user first lands on, to log in.
class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreennState createState() => _LogInScreennState();
}

//Tutorial followed to create page: https://www.youtube.com/watch?v=GvIoBgmNgQw&t=2151s
//Code has been adapted from the tutorial.
class _LogInScreennState extends State<LogInScreen> {
  //We need the _auth to check if the user has an account.
  final AuthService _auth = AuthService();
  //We have a inputs needed from the user.
  //Their password.
  TextEditingController password = TextEditingController();
  //Their email.
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          //We want the background to have a gradient colour.
          Container(
        width: MediaQuery.of(context)
            .size
            .width, //Sets the width to the width of the screen.
        height: MediaQuery.of(context)
            .size
            .height, //Sets the height to the height of the screen.
        decoration:
            //Gradient used for the background.
            BoxDecoration(
                gradient: LinearGradient(
                    colors: [
              hexStringToColor("9780d8"), //Lighter shade of the main colour.
              hexStringToColor("471dbc"), //Main colour for the app.
            ],
                    begin: Alignment.topCenter,
                    end: Alignment
                        .bottomCenter)), //Adding the alignement of the gradient.
        child:
            //Page can be scollable.
            SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                left: 20,
                top: (MediaQuery.of(context).size.height * 0.2),
                right:
                    20), //Padding for the log in page. Centres the logo and the input fields.
            child: Column(
              children: <Widget>[
                Image.asset("assets/bu.png",
                    fit: BoxFit.fitWidth,
                    width: 400,
                    height: 300), //Logo for the app shown.
                const SizedBox(
                    height:
                        20), //Creates a gap between logo and the input fields.
                customTextInput("Enter Email", Icons.mail_outline, false,
                    email), //Use a custonTextInput to show the input box.
                const SizedBox(
                  height: 20,
                ),
                customTextInput(
                    "Enter Password",
                    Icons.lock_outline_sharp,
                    true,
                    password), //Use a custonTextInput to show the input box, setting value to true makes password not visible.
                const SizedBox(
                  height: 5,
                ), //Gap to the forgot Passed button.
                forgetPasswordButton(
                    context), //Shows the forgot password button.
                //Custom button used as the Log In button.
                longButton(context, "Log In", () {
                  //Pass the button a function, that is run when the button is pressed.
                  //This function is to signInWithEmailAndPassword from FirebaseAuth.
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email.text, password: password.text)
                      .then((value) async {
                    //Then once the signIn is successful we need to add the user data into the right document -
                    //inside the Firebase collection users.

                    //We access the collection users from firebase.
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.getUid())
                        .get()
                        .then((value) async {
                      //Once we have the data on the current user we need to update a few fields.
                      var userData = value
                          .data(); //Setting the user data into a variable called userData.

                      //We check if the user has logged on before.
                      if (userData!['log_on_time'] == '') {
                        //if they have not we need to create a default time limit for them.
                        var limit = const Duration(hours: 2).toString();

                        //Now we can data that we want to update.
                        Map<String, dynamic> data = {
                          'status': 'Online', //User is about to be Online.
                          'log_on_time':
                              DateTime.now(), //User about to log on now.
                          'active_time': 0, //They have not been active.
                          'default_time_limit':
                              limit, //Setting the default time.
                          'changed_limit':
                              false //They have not changed their time limit yet.
                        };
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.getUid())
                            .update(
                                data); //Then we update the data inside the collection.
                      }
                      //If a user has logged on before we do not need to set the default limit.
                      else {
                        //We need to create the data that we want to use.
                        Map<String, dynamic> data = {
                          'status': 'Online', //User is about to be Online.
                          'log_on_time':
                              DateTime.now(), //User about to log on now.
                          'active_time': 0, //Resetting their active time.
                          'log_off_time':
                              '' //This field is added when the user is logged out of the application, now they are online we can make it blank.
                        };
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.getUid())
                            .update(
                                data); //Update that data inside the collection.
                      }
                    });

                    //After adding all the data to the collection we push the user to the homepage of the application.
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const HomePage()));
                    //If there is an error when logging in this needs to be handled.
                  }).onError((error, stackTrace) {
                    //We format the error so that in some cases it can be shown back to user.
                    //Code adapted from: https://stackoverflow.com/questions/70609591/remove-text-between-parentheses-in-dart-flutter
                    String formatError =
                        error.toString().replaceAll(RegExp('\\[.*?\\]'), '');
                    //We check what error it is.
                    if (formatError.contains('password')) {
                      //If it is password related we need to tell the user the password is not vaild.
                      passwordError(
                          context); //No need to return the error back to the user as we know that it will not be vaild.
                    }
                    //We check if the error is to do with the email.
                    else if (formatError.contains('email')) {
                      emailError(context,
                          formatError); //Could be a number of error with the email address so the error is returned to the user in a readable formatt.
                    }
                    //If the error has nothing to do with the email or the password.
                    else {
                      //Then we return the error back to the user.
                      otherLogInError(context, formatError);
                    }
                  });
                }),
                signUpButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

//We need a sign up option for the user if they do not have an account.
  Row signUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(
                color:
                    Colors.white70)), //Styled like a lot of other applications.
        //Catch when the user presses the sign up button.
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SignUpScreen())); //Sends the user to the sign up page.
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ), //In bold so that it stands out from the rest of the text in this row.
        )
      ],
    );
  }

  //We need a button for the users who have forgotten their passwords.
  Widget forgetPasswordButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child:
          //Text button used.
          TextButton(
              child: const Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.right,
              ),
              //When user presses the button we need to execute some code.
              onPressed: () {
                //Push the user to the forgot password page.
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ResetPassword()));
              }),
    );
  }
}

//Below are the collection of error pop ups we need to inform the user that there was a problem when the were attempted a log in.

emailError(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return CupertinoAlertDialog(
          //Alerts the user to an error with the email.
          //This will show the user if there is a problem with logging into their account, due to the email.
          title: const Text("Invaild Email"),
          content: Text(
            "\nThere was an error with the email, please try agian.\n\nHint:${error.toString()}",
          ),
        );
      });
}

passwordError(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return const CupertinoAlertDialog(
          //Alerts the user to an error with the password.
          //This will show the user if there is a problem with logging into their account, due to the password.
          title: Text("Invaild Password"),
          content: Text(
            "\nThere was an error with the password, please try agian.\n\nHint: The password is invalid.",
          ),
        );
      });
}

otherLogInError(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return CupertinoAlertDialog(
          //Alerts the user to an error with the log in.
          //This will show the user if there is a problem with logging into their account.
          title: const Text("Log In Error"),
          content: Text(
            "\nThere was an error when logging in, please try agian.\n\nHint:${error.toString()}",
          ),
        );
      });
}
