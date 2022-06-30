import 'package:beyou/services/auth.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

//This class shows the locked page for when the user has passed their time limit.
class TimeLimitPage extends StatefulWidget {
  const TimeLimitPage({Key? key}) : super(key: key);
  @override
  _TimeLimitPageState createState() => _TimeLimitPageState();
}

class _TimeLimitPageState extends State<TimeLimitPage> {
  //Need auth as we are querying the database.
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    //Need show the screen to the user.
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Text(
                'Time Limit Reached',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ), //Inform the user that they have reached their time limit.
            //Keeps the same style as the other main pages of the app.
            const SizedBox(
              height: 10,
            ), //Gap from the title.
            //Show the companion sleeping.
            Center(
                child:
                    //Large SizedBox to store the companion in.
                    SizedBox(
                        width: 300,
                        height: 400,
                        child: RiveAnimation.asset(
                          "assets/new_file.riv",
                          controllers: [
                            SimpleAnimation('Sleepy')
                          ], //Set the character to sleepy.
                          //This makes it seem like the character is a asleep.
                          fit: BoxFit.fitHeight,
                          alignment: Alignment
                              .center, //Make the colour grey as it will look good against a white card.
                        ))),

            const SizedBox(
              height: 15,
            ), //Gap from the character to the messages shown to the user.
            const Padding(
              padding: EdgeInsets.all(
                  15.0), //Padding needed to wrap the text and ensure there is no overflow error.
              child: Text(
                'You have reached the time limit for activity today. This limit is changable on your profile page. You are able to go pass this limit, by pressing the button below.',
                //Text tells the user that they have reached their limit.
                textAlign: TextAlign.center, //Keep the text in the centred.
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
            const SizedBox(
              height: 30,
            ), //Gap from message to the button.
            ElevatedButton(
              //More time button needs to give the user more activitiy time.
              style:
                  //ElevatedButton button used in the style of the app.
                  ElevatedButton.styleFrom(
                      primary: hexStringToColor('471dbc'),
                      elevation: 8,
                      shadowColor: Colors.black),

              child: const Text(
                'More Time Please',
                style: TextStyle(color: Colors.white),
              ), //More time text in white to cause the contrast from the purple button.

              //When the button is pressed we need to increase the time for the user.
              onPressed: () {
                //This is done by resetting the active_time field and the log_on_time.
                Map<String, dynamic> data = {
                  'log_on_time': DateTime.now(),
                  'active_time': 0
                };
                //Difference from log_on_time to current time is how the active time is counted -
                //so it needs to be reset.
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.getUid())
                    .update(
                        data); //Update this users log_on_time and active_time fields respectively
                //Must send the user back to the page they were on before the time limit page was shown.
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
