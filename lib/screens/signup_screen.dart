import 'package:beyou/services/auth.dart';
import 'package:beyou/widgets/input_buttons_widget.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//This class shows the sign up screen which allows users to create an account.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

//Tutorial followed to create page: https://www.youtube.com/watch?v=GvIoBgmNgQw&t=2151s
//Code has been adapted from the tutorial.
class _SignUpScreenState extends State<SignUpScreen> {
  //We need _auth as we are going to create a new user.
  final AuthService _auth = AuthService();
  //The TextEditingController for all the inputs
  final TextEditingController name = TextEditingController(); //For the name
  final TextEditingController username =
      TextEditingController(); //For the username
  final TextEditingController email = TextEditingController(); //For the email

  final TextEditingController password =
      TextEditingController(); //For the password
  final TextEditingController companion =
      TextEditingController(); //For the companion name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Needed to show transparent AppBar.
      extendBodyBehindAppBar: true,
      //The app bar is the same the the reset password app bar.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            //Sends user back to login page.
            Navigator.pop(context);
          },
        ),
      ),
      //The body needs to contain the input fields.
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context)
              .size
              .height, //Sets the gradient to the whole screen.
          decoration:
              //Same gradient design as the other pages, login and reset password.
              BoxDecoration(
                  gradient: LinearGradient(colors: [
            hexStringToColor("9780d8"),
            hexStringToColor("471dbc"),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          //Setting the padding to prevent any overflow errors.
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 120, right: 20),
            //Column to hold the input field and the button.
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ), //Gap from the app bar.
                  customTextInput("Enter Name", Icons.person_outline, false,
                      name), //Input field for name.
                  const SizedBox(
                    height: 20,
                  ), //Gap from name input.
                  customTextInput("Enter Username", Icons.person_outline, false,
                      username), //Input field for username.
                  const SizedBox(
                    height: 20,
                  ), //Gap from username input.
                  customTextInput("Enter Email", Icons.email_outlined, false,
                      email), //Input for email.
                  const SizedBox(
                    height: 20,
                  ), //Gap from email input.
                  customTextInput(
                      "Enter Password",
                      Icons.lock_outline_sharp,
                      true,
                      password), //Password input, so value is set to true to hide the text.
                  const SizedBox(
                    height: 20,
                  ), //Gap from password input field.
                  customTextInput("Companion Name", Icons.pets, false,
                      companion), //Input field for name of companion.
                  const SizedBox(
                    height: 20,
                  ), //Gap from password input field.
                  //Sign up button.

                  longButton(context, "Sign Up", () {
                    //Need to check that all the fields have the required data.
                    if (name.text == '' ||
                        username.text == '' ||
                        email.text == '' ||
                        password.text == '' ||
                        companion.text == '') {
                      //Show  missing fields dialog.
                      noText(context);
                    } else {
                      if (username.text.indexOf(' ') >= 0) {
                        //Username error.
                        usernameError(context);
                      } else {
                        //Calls the method that we use to create the account.
                        createUser(context, name.text, username.text,
                            email.text, password.text, companion.text);
                      }
                    }
                  })
                ],
              ),
            ),
          )),
    );
  }

  createUser(context, name, username, email, password, companion) {
    //Uses the createUser method from the AuthService class to create the user.
    _auth.authNewUser(name, username, email, password, companion).then((value) {
      //If the sign up is successfull we send the user back to the login page.
      Navigator.pop(context);
    })
        //If there was an error with the sign up we need to show the prompts to the user.
        .onError((error, stackTrace) {
      //Same code from: LogInScreen Class.
      //We format the error so that in some cases it can be shown back to user.
      String formatError = error.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      //We check what error it is.
      if (formatError.contains('password')) {
        //If it is password related we need to tell the user the password is not vaild.
        signUpPasswordError(
            context); //Could be a number of error with the password on sign up so the error is returned to the user in a readable formatt.
      }
      //We check if the error is to do with the email.
      else if (formatError.contains('email')) {
        signUpEmailError(context,
            formatError); //Could be a number of error with the email address so the error is returned to the user in a readable formatt.
      }
      //If the error has nothing to do with the email or the password.
      else {
        //Then we return the error back to the user.
        otherSignUpError(context, formatError);
      }
    });
  }

//Need an error for a taken username.
  usernameError(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //CupertinoAlertDialog keeps with the current IOS theme.
          return const CupertinoAlertDialog(
            //Alerts the user to an error with the email.
            //This will show the user if there is a problem with logging into their account, due to the email.
            title: Text("Invaild Username"),
            content: Text(
              "\nThere was an error with the username, it was either poorly formatted or someone already owns it, please try agian.",
            ),
          );
        });
  }
}

//Take from: LogInScreen Class.
//Below are the collection of error pop ups we need to inform the user that there was a problem when the were attempted a log in.

signUpEmailError(context, error) {
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

signUpPasswordError(context) {
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

noText(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return const CupertinoAlertDialog(
          //Alerts the user to an error with the log in.
          //This will show the user if there is a problem with logging into their account.
          title: Text("Missing Fields"),
          content: Text(
            "\nThere was an error when signing up all fields need to be filled please try agian.",
          ),
        );
      });
}

otherSignUpError(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return CupertinoAlertDialog(
          //Alerts the user to an error with the log in.
          //This will show the user if there is a problem with logging into their account.
          title: const Text("Sign Up Error"),
          content: Text(
            "\nThere was an error when signing up, please try agian.\n\nHint:${error.toString()}",
          ),
        );
      });
}
