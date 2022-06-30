import 'package:beyou/screens/time_limit.dart';
import 'package:beyou/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Method can be is used across the App.
//This method checks the if the user has been active for too long.

checkTimeLimit(context) async {
  //We need AuthService as we are getting the users time limit from the firebase collection.
  AuthService _auth = AuthService();
  await FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.getUid()) //Current user id.
      .get()
      .then((value) {
    //We need the users log on time.
    var logOnTime; //Create variable for later.
    var docs = value.data(); //We save the information into docs variable.
    //New we check if the user has just logged on.
    //We can do so by ensuring that the log_on_time and log_off_time are the same.
    if (docs!['log_on_time'] == docs['log_off_time']) {
      //Data might not have updated in firebase so we update it.
      Map<String, dynamic> data = {
        'status': 'Online', //User is about to be Online.
        'log_off_time': '', //User is active so we change this to Null for now
        'log_on_time': DateTime.now(), //User about to log on now.
        'active_time': 0, //Resetting their active time.
      };
      FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.getUid())
          .update(data); //Update that data inside the collection.
      //We recall this method because there should be a log_on_time as it is set as the user logs in.
      //Recalling this method gives time of the data to be updated in firebase.
      checkTimeLimit(context);
    } else {
      //We can run the checks.
      //When there is a log_on_time we need to save it to the variable we created earlier.
      logOnTime = docs['log_on_time'].toDate();
      //We now need to know the difference between the current time and the users log on time, as -
      //this will be the active minutes for the user.
      var currentMins = DateTime.now()
          .difference(logOnTime)
          .inMinutes; //We save in minutes as it is easier.
      //We then need to create data that can be updated in the collection user.
      Map<String, dynamic> data = {'active_time': currentMins};
      FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.getUid())
          .update(data);
      //We check if the time limit has been changed.
      if (docs['changed_limit'] == true) {
        //If it has been then we need to access it.
        var userPicked = docs['user_time_limit'];
        //We save the limit from the database.

        userPicked = stringToDuration(
            userPicked); //We need to change the string to a duration .

        //We then check if the current mins is equal to or greater than the userpicked time limit in minutes.
        if (docs['active_time'] >= userPicked.inMinutes) {
          //If the limit has been passed we need to show the Time Limit page.
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const TimeLimitPage()));
        } else {
          //We do nothing.
        }
      }
      //If the user has not changed the time then we need to check use the default_time_limit from the database.
      else {
        //We save the defaultLimit.
        var defaultLimit = docs['default_time_limit'];

        //We then need to change the string to the duration.
        defaultLimit = stringToDuration(defaultLimit);

        //We then check if the current mins is equal or greater than the defaultLimit time limit in minutes.
        if (currentMins >= defaultLimit.inMinutes) {
          //If the limit has been passed we need to show the Time Limit page.
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const TimeLimitPage()));
        } else {
          //We do nothing.
        }
      }
    }
  });
}

//Method adapted from parseDuration, found: https://stackoverflow.com/questions/54852585/how-to-convert-a-duration-like-string-to-a-real-duration-in-flutter
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
