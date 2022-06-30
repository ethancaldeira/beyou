import 'package:beyou/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';

//Class for the Change Limit page.
class ChangeTimeLimitPage extends StatefulWidget {
  const ChangeTimeLimitPage({Key? key}) : super(key: key);

  @override
  _ChangeTimeLimitPageState createState() => _ChangeTimeLimitPageState();
}

class _ChangeTimeLimitPageState extends State<ChangeTimeLimitPage> {
  final AuthService _auth = AuthService();
  //Sets the duration values needed for changing the users preferences.
  Duration currentLimit = const Duration(hours: 0, minutes: 0);
  Duration selectedValue = const Duration(hours: 0, minutes: 0);

  //Inside the init state, find the current limit for the user.
  @override
  void initState() {
    findCurrentLimt();
    super.initState();
  }

  //This method is needed in order to show the duration back to the user
  String showDuration(Duration duration) {
    //Create method to take an int value into a String.
    String intToString(int n) => n.toString().padLeft(2, "0");
    //Changes minutes of the duration into string value.
    String duartionMinutes = intToString(duration.inMinutes.remainder(60));
    //Returns the duration into a string.
    return "${intToString(duration.inHours)}:$duartionMinutes";
  }

  //Method adapted from parseDuration, found:https://stackoverflow.com/questions/54852585/how-to-convert-a-duration-like-string-to-a-real-duration-in-flutter
  Duration stringToDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  //Method below is to find what the current time limit is for the user.
  void findCurrentLimt() async {
    //Accessing the Firebase collection users to find what the user set their time limit to.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .get()
        .then((value) {
      var doc = value.data();
      //This field inside the collection is to show whether or not the user has changed their time limit from the default two hours.
      if (doc!['changed_limit'] == true) {
        //If the user has changed their time limit from the default then the field user_time_limit is accessed from the database.
        var userCurrentLimit = doc['user_time_limit'];
        //Sets the the attribute currentLimit to the value found inside the database.
        setState(() {
          //Sets current limit to duration.
          //Using stringToDuration the string from the database can become type duration.
          currentLimit = stringToDuration(userCurrentLimit);
        });
      } else {
        //If the user has not changed their default time limit, then the respective field is accessed.
        var userCurrentLimit = doc['default_time_limit'];
        setState(() {
          //Sets current limit to default duration.
          //Uses stringToDuration as the default limit is also stored as a string insed the database.
          currentLimit = stringToDuration(userCurrentLimit);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same style AppBar as the rest of the app
      appBar: AppBar(
          title: Text(
            'Time Limit Settings',
            style: TextStyle(color: hexStringToColor("471dbc")),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor("471dbc"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ), //Sized box used so that the there is a gap between the header and the contents of the page.
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text('Default Limit is set to: 2 hours',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: hexStringToColor('471dbc'),
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
              ), //This padding holds text shows the user what the default time limit is
              //This text is just to remind the user, as they cannot interact with the text.
            ],
          ),
          const SizedBox(
            height: 50,
          ), //Gap between the two texts.
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                    //Shows the current limit by using the showDuration which displays -
                    //the duration in the right way.
                    'Current Limit is set to: ${showDuration(currentLimit)}',
                    //As it uses the attrubute of currentLimit the time will change as the user selects a new time.
                    //Below are the style settings for the text.
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: hexStringToColor('471dbc'),
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ), //Gap between the text and the button
          CupertinoButton(
            child: const Text("Edit Time Limit"),
            onPressed: () {
              //Creates the time limit picker for the user.
              buildTimeLimitPicker();
            },
          ), //Using CupertinoButton to show that the user can edit the time limit.
          //CupertinoButton style used as Cupertino timer picker also used on this page.
        ],
      ),
      //floatingActionButton used to save the new limit the user has selected.
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.check,
            semanticLabel: 'Save',
          ),
          backgroundColor: hexStringToColor('2e3887'),
          onPressed: () async {
            //Checks if the time limit is set to 0, as a way of handling a potential error.
            if (currentLimit == const Duration(hours: 0, minutes: 0)) {
              //Display a dialog to the user to inform about the problem.
              timeLimitError(context);
              //Does not add the new time limit to the database.
            }
            //Checks if the user is trying to set a time limit lower than 10 minutes.
            //By setting a time limit below 10 minutes the user may set a time limit to 2 minutes which may cause potential error.
            else if (currentLimit < const Duration(hours: 0, minutes: 10)) {
              //Display a dialog to the user to inform about the problem.
              timeLimitError(context);
              //Does not add the new time limit to the database.
            }
            //Checks if the user is trying to set a time limit lower higher than 20 hours.
            //By setting a time limit higher than 20 hours the application will never lock in a day.
            else if (currentLimit > const Duration(hours: 20, minutes: 0)) {
              //Display a dialog to the user to inform about the problem.
              timeLimitError(context);
              //Does not add the new time limit to the database.
            }
            //If the user has entered a vaild time limit.
            else {
              //Updates the correct field values inside the user collection.
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth
                      .getUid()) //Ensures its the right user being updated.
                  .update({
                'changed_limit':
                    true, //Changes the bool value of changed_limit as the user has now changed their time limit.
                'default_time_limit': FieldValue
                    .delete(), //Deletes the default_time_limit field as they have now changed their time limit.
                'user_time_limit': currentLimit
                    .toString() //Adds the new time limit as a string.
              });
              //Naviagates the user back to the profile page and refreshes the page.
              navigate(context);
            }
          }),
    );
  }

  //Creates the time limit picker for the user
  void buildTimeLimitPicker() {
    //Using the CupertinoTimePicker to do so.
    //Need to show the Cupertino pop up.
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          //Container contains the time picker inside it.
          return Container(
              //Returns a Container that is the width of the page, but only takes up a quarter of the pages height.
              height: MediaQuery.of(context).copyWith().size.height * 0.25,
              width: double.infinity,
              color: Colors.white,
              //CupertinoTimerPicker allows user to slide the time to select their new limit.
              child: CupertinoTimerPicker(
                //Set the mode to just hours and minutes, as seconds are not needed for the time limit.
                mode: CupertinoTimerPickerMode.hm,
                //Sets the initial value to currentLimit the from the database.
                initialTimerDuration: currentLimit,
                //When the slider is used and a new time is picked.
                onTimerDurationChanged: (value) {
                  //Changes the value of current limit to the new selected value.
                  //Happens dynamically, so the user can see it change behind the pop up.
                  setState(() {
                    currentLimit = value;
                  });
                  //This means when the user clicks off the picker the value will be set to the value they landed the slider on.
                },
              ));
        });
  }

  //Navigate to profile page method.
  void navigate(context) {
    //Shows a pop up dialog to show the user that the value is vaild.
    successTest(context);
    //Delay the push back to the profile page by 1 seconds.
    //Gives enough time for the values to be added to the database in this time.
    Future.delayed(const Duration(seconds: 1), () {
      //Refreshes the profile page as they land on it.
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfilePage())).then((value) => setState(() {}));
    });
  }
}

//Returns a pop up dialog to tell the user that the limit has been updated.
successTest(context) {
  showDialog(
      //Ensures that the user cannot dismiss the pop up by click else where on the screen.
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        //Returns the CupertinoAlertDialog to stay the same as the other pop ups in the app.
        return const CupertinoAlertDialog(
          title: Text("Successful Updated"),
          content: Text(
            "\nThe new time limit has been updated successfully!",
          ), //Informs the user the limit has now changed.
        );
      });
}

//Returns a pop up dialog to tell the user that their new limit is not valid.
timeLimitError(context) {
  showDialog(
      //No need for barrierDismissible: true, as it automatically has the value set to true so that the users can dismiss the alert dialog -
      //By pressing elsewhere on the screen.
      context: context,
      builder: (BuildContext context) {
        //Returns the CupertinoAlertDialog to stay the same as the other pop ups in the app.
        return const CupertinoAlertDialog(
          title: Text("Not a Vaild time limit"),
          content: Text(
            "\nPlease add a vaild limit agian. The limit cannot be less than 10 minutes and cannot be more than 20 hours. Try a value within these times.",
          ), //Informs the user of what a valid time limit is, and asks them to try again.
        );
      });
}
