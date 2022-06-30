import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../services/auth.dart';

//Character Controller allows us to control the companions state.
//We do that with this method below.
//We take an id as the parameter before we can run any querys to the database.
calculateState(id) async {
  //We connect with AuthService as we need to query the database.
  final AuthService _auth = AuthService();
  //We check if the id is equal to 'this_user', this allows us to to give the parameter of _auth.getUid() as we can do it locally.
  if (id == 'this_user') {
    //if it is we can reset the id to the actual unique id of the current user.
    id = _auth.getUid();
  }
  //Now we need to set the values which determine the state of the companion.
  int entriesToday = 0; //Entries posted today.
  int entriesTotal = 0; //Entries posted all time.
  int exercisesToday = 0; //Exercises done today.
  String userMood =
      ''; //The users current mood which we do not know so we save as ''.
  String character = 'Character'; //This allows us to name the character.

  bool isMoving =
      false; //This will make the character walk if this bool value is set to true.

  //The first query is to find the total entries of the specific user.
  await FirebaseFirestore.instance
      .collection("entries")
      .where('owner_id', isEqualTo: id) //Query the given id.
      .get()
      .then((value) {
    //Save the value to the variable we set up earlier.
    entriesTotal = value.docs.length;
  });
  //The next query is to check the entries done today.
  await FirebaseFirestore.instance
      .collection('entries')
      .where('owner_id', isEqualTo: id) //Query the given id.
      .where('formatted_date',
          isEqualTo: DateFormat('dd/MM/yyyy')
              .format(DateTime.now())
              .toString()) //Only looking for todays entries.
      .get()
      .then((value) {
    //Save the value to the variable we set up earlier.
    entriesToday = value.docs.length;
  });

  //The next query is to find the mood rating of the specific user.
  await FirebaseFirestore.instance
      .collection("entries")
      .where('owner_id', isEqualTo: id) //Given id.
      .where('tag',
          isEqualTo: 'mood') //Ensures we are looking at mood check ins.
      .where('formatted_date',
          isEqualTo: DateFormat('dd/MM/yyyy').format(DateTime.now()).toString())
      .orderBy("date",
          descending:
              true) //We want to organise this as we want the lastest mood check in.
      .get()
      .then((value) {
    //We check that there are mood entries.
    if (value.docs.isNotEmpty) {
      //We then save the mood rating of the user.
      int userMoodRating = value.docs[0]['mood_rating'];
      //We then need to find out whether the rating determines if they are down or happy.
      if (userMoodRating <= 3) {
        //Save the value to the variable we set up earlier.
        userMood = 'down'; //Less then 3 and the user is down.
      } else {
        //Save the value to the variable we set up earlier.
        userMood = 'happy'; //More than 3 the user is happy.
      }
    }
  });
  //For the last query we need to check their exercises for today.
  await FirebaseFirestore.instance
      .collection('exercises')
      .where('owner_id', isEqualTo: id) //Given id.
      .where('formatted_date',
          isEqualTo: DateFormat('dd/MM/yyyy')
              .format(DateTime.now())
              .toString()) //Looking for current exercises.
      .get()
      .then((value) {
    //Saving the exercises today to the variable we set up earlier.
    exercisesToday = value.docs.length;
  });

  //We want to check the sensors without including gravity.
  userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //These are the velocity in directions for the device.
    var x = event.x; //Velocity in x
    var y = event.y; //Velocity in y. Without gravity this is.
    var z = event.z; //Velocity in z.
    //Taken form CalmWalkDisplay() class.
    //Need to make sense of the magnitude of the movement.
    double movement = sqrt(x * x + y * y + z * z);
    //If the movement has shown a large change then the user is moving.
    if (movement > 6) {
      isMoving = true;
    }
  });
  //We need the name that the user gives to the companion.
  await FirebaseFirestore.instance
      .collection("users")
      .where(FieldPath.documentId, isEqualTo: id) //Query the given id.
      .get()
      .then((value) {
    //Save the value to the variable we set up earlier, for the companion name.
    //Do not change the name of the companion if the user has not picked a name.
    if (value.docs[0]['companion_name'] == "" ||
        value.docs[0]['companion_name'] == " ") {
    } else {
      //If they have we can.
      character = value.docs[0]['companion_name'];
    }
  });

  //Now we need to check the data we saved.
  //We first want to have the character walking if the user is walking.
  if (isMoving == true) {
    //The companion will be walking as the user is also walking.
    String message =
        ('$character is walking with you.'); //We can save a unique message for the user.

    //We then need to create a list that will store the feeling of the companion and the message.

    List stateList = ['"Walk"', '"$message"']; //Walking STATE
    //stateList[0] is the state of the companion.
    return stateList; //Return the list.

  }
  //If the user has not ever created an entry.
  else if (entriesTotal == 0) {
    //The companion will be sad as the user is not using the app.
    String message =
        ('$character is sad, because you have not added any entries'); //We can save a unique message for the user.

    //We then need to create a list that will store the feeling of the companion and the message.

    List stateList = ['"Sad"', '"$message"']; //SAD STATE
    //stateList[0] is the state of the companion.
    return stateList; //Return the list.

  }
  //If the user has not created an entry today.
  else if (entriesToday == 0) {
    //The companion will be sad as the user has not been using the app for the day.
    String message =
        ('$character is sad, because there are no entries today'); //We can save a unique message for the user.
    //We then need to create a list that will store the feeling of the companion and the message.

    List stateList = ['"Sad"', '"$message"']; //SAD STATE
    //stateList[0] is the state of the companion.
    return stateList; //Return the list.

  }
  //If the user has been posting entries today, we need to check the mood of the user.
  else if (userMood == 'down') {
    //This mood is only for the lastest mood check in.
    //The companion will be playful if the user has said they are feeling down.
    //This is to cheer up the user.
    String message =
        ('$character is playful to try cheer you up from being $userMood'); //We can save a unique message for the user.
    //We then need to create a list that will store the feeling of the companion and the message.
    List stateList = ['"Jump"', '"$message"']; //PLAYFUL STATE
    //stateList[0] is the state of the companion, playful not the name of the state, jump is.
    return stateList; //Return the list.
  }
  //Checking the time the user is using the application between.
  else if (DateTime.now().hour >= 21 || DateTime.now().hour < 6) {
    //The companion will be tired as if the user is using the app between 9 at night and 6 in the morning.
    //So we have the character be asleep.
    String message =
        ('$character is tired'); //We can save a unique message for the user.
    //We then need to create a list that will store the feeling of the companion and the message.
    List stateList = ['"Sleepy"', '"$message"']; //SLEEPY STATE
    //stateList[0] is the state of the companion.
    return stateList; //Return the list.
  }
  //Checking if the user has written more then 4 entries.
  else if (entriesToday >= 4) {
    //The companion will be reading as if the user has written more then 4 entries as the companion will be 'reading' the entries.
    String message =
        ('$character is reading all the entries '); //We can save a unique message for the user.
    //We then need to create a list that will store the feeling of the companion and the message.
    List stateList = ['"Read"', '"$message"']; //READING STATE
    //stateList[0] is the state of the companion.
    return stateList; //Return the list.

  }
  //We check that the user has created entries and exercised for the day.
  else if (entriesToday > 0 && exercisesToday > 0) {
    //If that is the case the companion will be really happy.
    String message =
        ('$character is SUPER happy because you have journaled & worked out'); //We can save a unique message for the user.
    //We then need to create a list that will store the feeling of the companion and the message.
    List stateList = ['"Happy"', '"$message"']; //Happy state
    //stateList[0] is the state of the companion.
    return stateList; //Return the list.

  }
  //Then the last thing we need to check is that the user has created an entry today.
  else if (entriesToday > 0) {
    //If that is the case the companion will be  happy.
    String message =
        ('$character is happy because you have added an entry today'); //We can save a unique message for the user.
    //We then need to create a list that will store the feeling of the companion and the message.
    List stateList = ['"Happy"', '"$message"']; //HAPPY STATE
    //stateList[0] is the state of the companion.
    return stateList;
  }
  //If non that those values are meet we need to return the idle state of the character.
  return 'Idle';
}
