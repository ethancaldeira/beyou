import 'package:firebase_auth/firebase_auth.dart';
import 'package:beyou/widgets/input_buttons_widget.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//This class is for users who have forgot their password, and need to reset it.
class ResetPassword extends StatefulWidget {
  //No parameters needed.
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

//Tutorial followed to create page: https://www.youtube.com/watch?v=JR-jEbfQciw
//Code has been adapted from the tutorial.
class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Needed to show the transpearent app bar.
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
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
      //Container to hold the input field for the email.
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration:
              //Same design as the other pages before the user logs in.
              BoxDecoration(
                  gradient: LinearGradient(colors: [
            hexStringToColor("9780d8"),
            hexStringToColor("471dbc"),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child:
              //Setting the padding to prevent any overflow errors.
              Padding(
            padding: const EdgeInsets.only(left: 20, top: 120, right: 20),
            //Column to hold the input field and the button.
            child: Column(
              children: <Widget>[
                //Gap from the app bar.
                const SizedBox(
                  height: 20,
                ),
                //Input field for the email.
                customTextInput(
                    "Enter Email ", Icons.mail_outline, false, email),
                //Gap from the input email field.
                const SizedBox(
                  height: 20,
                ),
                //Using the longAuthButton to reset the password.
                longButton(context, "Reset Password", () {
                  //Firebase has a built in method to send a reset password email.
                  FirebaseAuth.instance
                      .sendPasswordResetEmail(
                          email: email.text) //Send the email to the user.
                      .then((value) => Navigator.of(context)
                          .pop()) //Sends user back to the previous page.
                      //Checks if the email was entered wrong.
                      .onError((error, stackTrace) {
                    //We format the error so that in some cases it can be shown back to user.
                    String formatError =
                        error.toString().replaceAll(RegExp('\\[.*?\\]'), '');
                    //Shows the error to the user.
                    emailError(context, formatError);
                  });
                })
              ],
            ),
          )),
    );
  }
}

//Taken from the LogInScreen class.
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
