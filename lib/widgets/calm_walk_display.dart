import 'dart:async';
import 'dart:math';

import 'package:beyou/services/auth.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database.dart';

//This class shows the calm walk card to the user.
//Code adapted from tutorial: https://www.youtube.com/watch?v=b_hqqDJIJKE
class CalmWalkDisplay extends StatefulWidget {
  const CalmWalkDisplay({Key? key}) : super(key: key);

  @override
  _CalmWalkCardState createState() => _CalmWalkCardState();
}

//Displays the card to the user.
class _CalmWalkCardState extends State<CalmWalkDisplay> {
  //We need AuthService as we are going to query the database.
  final AuthService _auth = AuthService();
  //We need the walking controller to start the companions walking animation.
  late RiveAnimationController walkingController;
  //We need to check if the button was pressed.
  bool isPressed = false;
  //We are setting the x,y,z values that will be changed later when we read the accelormeter events.
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  //Setting steps that will be updated later.
  int steps = 0;
  //Setting all the measurements to show the user.
  int miles = 0;
  int calories = 0;
  //Setting the previous and current movement.
  double previousMovement = 0.0;
  double movement = 0.0;
  //Need a duration and timer to count up
  Duration duration = Duration();
  Timer? timer;

  //We use the start walk method to start the companions walk.
  void startWalk() => setState(
        //Sets the controller on and off based on its current state.
        () => walkingController.isActive = !walkingController.isActive,
      );

  @override
  void initState() {
    super.initState();
    //We want to initialise the controlelrs.
    initControllers();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  //Here we set the walking animation for the companion.
  void initControllers() {
    walkingController = SimpleAnimation('Walk',
        autoplay:
            false); //Autoplay to false means it will not play until it is activated.
  }

  //Dispalying the card to the user.
  @override
  Widget build(BuildContext context) {
    //Need to include the companion as the button press on the card will change the state of the companion.
    return Column(
      children: [
        //Sized box to fit the companion in.
        SizedBox(
            height: 350,
            width: 400,
            child: RiveAnimation.asset("assets/new_file.riv", controllers: [
              SimpleAnimation('Idle'),
              walkingController
            ])), //Setting up the animation controllers.
        //Card to contain all the information.
        Card(
          shadowColor: Colors.black,
          elevation: 8,
          //Keep the card rounded.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ), //Setting the colour to white will match the other cards for the exercises.
            child: Column(
              children: [
                //Now we need to store the information.
                const SizedBox(height: 25),
                const Align(
                    alignment: Alignment.center,
                    child: Text('Start a Walk',
                        style: TextStyle(
                            fontSize: 20))), //Title set with its size.
                const SizedBox(
                  height: 25,
                ), //Gap from title.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      //Expanded avoids the overflow errors.
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            //Below is the step counter.
                            SizedBox(
                              width: 150,
                              child: Row(
                                children: [
                                  Text(
                                    steps
                                        .toString(), //Takes the parameter steps and displays it.
                                    style: const TextStyle(
                                        fontSize:
                                            50), //Size set to 50 so that it is large to see.
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ), //Gap from the steps to the other information.
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Buts a divider between the the steps and the play.
                      const SizedBox(
                        width: 130,
                      ),
                      //Below is the play and pause button.
                      Expanded(
                        flex: 1,
                        child: Center(
                            child: IconButton(
                          icon: isPressed ==
                                  false //Checks that the button has not been pressed.
                              ? const Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                ) //The play button shown if the button is not pressed.
                              : const Icon(
                                  Icons.pause,
                                  size: 50,
                                ), //Pause button that shows if the play button is pressed.
                          onPressed: () {
                            //If the button is pressed we need to see what state the button is in.

                            setState(() {
                              //If it has not been pressed we make the button pressed.
                              if (isPressed == false) {
                                isPressed = true;
                                //We then call the method for to calculate steps.
                                calculateSteps();

                                //This will show us the pause button.
                                startWalk(); //Will also start the walking of the companion
                              } else {
                                //Else we need to pause the walking so the play button is shown again.
                                isPressed = false;
                                //We then call then pause the method for to calculate steps.
                                calculateSteps().pause;
                                //And the walking is stopped.
                                startWalk(); //Stops the animation of the walking companion.
                              }
                            });
                          },
                        )),
                      ),
                      //Gap from the button to the edge of the card.
                      const SizedBox(
                        width: 25,
                      ),
                    ],
                  ),
                ),
                //Now we need a hieght box for the information at the button of the card.
                const SizedBox(
                  height: 50,
                ),
                //Row holds all the information that we are given.
                Row(
                  children: [
                    //Gap from the edge of the card so that there is no overflow error.
                    const SizedBox(
                      width: 20,
                    ),
                    //First set of information.
                    //Distance.
                    Column(
                      children: [
                        const Icon(Icons
                            .directions_run), //Running icon shows distance.
                        Text(miles.toStringAsFixed(
                            1)), //Parameter shown and rounded to the first decimal place.
                        const Text(
                            'Distance'), //Distance text to explain what is being displayed.
                      ],
                    ),
                    //Spacer allows even gaps between the information.
                    const Spacer(),
                    //Calories shown to the user.
                    Column(
                      children: [
                        const Icon(Icons
                            .local_fire_department), //Fire icon to show that calories have been burnt.
                        Text(calories.toStringAsFixed(
                            1)), //Parameter shown and rounded to the first decimal place.
                        const Text(
                            'Calories'), //Calories shown to the user so it is being explained what is being displayed.
                      ],
                    ),
                    //Spacer allows even gaps between the information.
                    const Spacer(),
                    //Duration shown to the user.
                    Column(
                      children: [
                        const Icon(Icons
                            .watch_later_rounded), //Watch to show that the duration is being measured.
                        Text(formatDuration(duration)),
                        const Text(
                            'Duration'), //Duration shown to the user so it is being explained what is being displayed.
                      ],
                    ),
                    //Gap from the edge of the card so that there is no overflow error.
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                //We need the user to save their walk data.
                isPressed == true
                    //If the have pressed the play button it will show with the save option.
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 15), //Padding stops the overflow error.
                        child: SizedBox(
                            //Text button to show the save option.
                            child: TextButton(
                                onPressed: () async {
                                  //If the parameters are 0, they should not be able to save their data.
                                  if (calories == 0 ||
                                      duration.inMinutes.toInt() == 0 ||
                                      miles == 0 ||
                                      steps.toString() == 0) {
                                    //We need to return to the user the fact that there is no recorded data.
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          //Prompt matches the other prompts within the app.
                                          return noMeasurements;
                                        });
                                  }
                                  //Else if all the parameter are not 0 there is recorded data that can be saved.
                                  else {
                                    Map<String, dynamic> exerciseData = {
                                      //the user id needs to be saved.
                                      "owner_id": _auth.getUid(),
                                      //The users, username is saved.
                                      "owner_username": await DatabaseService(
                                              uid: _auth.getUid())
                                          .retreiveUsername(),
                                      //The calories is saved.
                                      "calories": calories.toStringAsFixed(1),
                                      //The duration is saved.
                                      "duration": duration.inMinutes.toString,
                                      //The distance is saved.
                                      "distance": miles.toStringAsFixed(1),
                                      //The steps are saved.
                                      "steps": steps.toString(),
                                      //The date for the exercise is saved.
                                      "date": DateTime.now(),
                                      //The formatted date for the exercise is saved, this is so it can be ordered when it is displayed.
                                      "formatted_date": DateFormat('MM/dd/yyyy')
                                          .format(DateTime.now())
                                          .toString(),
                                    };
                                    //Now we need to upload the data to firebase.

                                    FirebaseFirestore.instance
                                        .collection('exercises')
                                        .add(
                                            exerciseData); //We add the collection of data into firebase.
                                    //We can then change the button to false as the data has been saved.
                                    setState(() {
                                      isPressed = false;
                                    });
                                  }
                                },
                                //We need to show the text save so that the user knows what the button is.
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: hexStringToColor('471dbc'),
                                      decoration: TextDecoration
                                          .underline), //Underlined shows that it is a button that can be pressed.
                                ))),
                      )
                    //If the button has not been pressed we do not need to show the save.
                    : Container(), //Blank container shown.
                //Sized box to stop the text button causing an overflow error.
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  calculateSteps() {
    //Need to start the timer as while as recording measurements.
    if (isPressed == true) {
      //We start the timer on the button click.
      startTimer();
    } else {
      //We cancel the timer on button click. But we do not reset timer, as the user is only pausing.
      timer?.cancel();
    }
    return userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      //These are the velocity in directions for the device.
      var x = event.x; //Velocity in x
      var y = event.y; //Velocity in y. Without gravity this is.
      var z = event.z; //Velocity in z.
      if (isPressed == true) {
        //We need to figure out how far the device has moved.
        movement = valueMoved(x, y, z);
        //If the movement has been large we need to count the steps.
        if (movement > 6) {
          steps++; //Increase the steps.
        }
        //Dynamically change the data shown to the user.
        setState(() {
          //Calculate the calories
          calories = calculateCalories(steps);
          //Calculate the miles.
          miles = calculateMiles(steps);
        });
      } else {
        //We do not do anything in this else
      }
    });
  }

  //The following timer methods have been taken from, AddEntry Class.
  //Starts the counting
  void startTimer() {
    //Increases the time shown by 1 second.
    timer = Timer.periodic(const Duration(seconds: 1), (_) => increaseTime());
  }

  void increaseTime() {
    if (mounted) {
      setState(() {
        //Then we add 1 to the seconds as it counts up this way.
        final seconds = duration.inSeconds + 1;
        //If the timer goes past 9 hours we need to stop it.
        if (seconds > 28800) {
          setState(() {
            timer?.cancel(); //Cancel the timer
          });
        } else {
          //If it has not surpassed 9 hours we can keep going.
          duration = Duration(seconds: seconds);
        }
      });
    }
  }

  //Method taken from the AddEntry Class
  //Adapted from: https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
  //We want to show the duration in the correct format.
  formatDuration(Duration duration) {
    //Changes the duration into string.
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    //Need hours.
    final hours = twoDigits(duration.inHours.remainder(60));
    //Need minutes.
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    //Returning the hours and minutes formatted the correct way
    return "$hours:$minutes:$seconds";
  }

  //Below are the the equations that caluate the steps, distance and duration of walk.
  //These methods are adapted from a tutorials: https://www.youtube.com/watch?v=IDTGdc3ScPY&t=1448s & https://www.youtube.com/watch?v=b_hqqDJIJKE
  //This method finds the value that has been moved.
  double valueMoved(double x, double y, double z) {
    //Finds the magnitude of how far the device has moved.
    double movement = sqrt(x * x + y * y + z * z);
    getPreviousMovement(); //Want to know the previous value of how far the device has moved.
    double newMovement = movement -
        previousMovement; //Creating the new movement value, by subtracting the old by the movement
    setPreviousMovement(
        movement); //Setting the previous movement to that of the new one.
    return newMovement; //Returnin the new moved distance.
  }

  //Method to set the old moved value.
  void setPreviousMovement(double distanceMoved) async {
    SharedPreferences _preference = await SharedPreferences.getInstance();
    _preference.setDouble("preMovement", distanceMoved);
  }

  //Method to get the old moved value.
  void getPreviousMovement() async {
    SharedPreferences _preference = await SharedPreferences.getInstance();
    setState(() {
      previousMovement = _preference.getDouble("preMovement") ?? 0.0;
    });
  }

  //Below methods are  adapted from: https://www.youtube.com/watch?v=IDTGdc3ScPY&t=1448s
  //Method to calculate the miles that have been done.
  int calculateMiles(int steps) {
    //Refrence for step length: https://chparks.com/411/How-To-Measure-Steps#:~:text=An%20average%20person%20has%20a,steps%20has%20many%20health%20benefits.
    //Average length of a stride is 2.2 feet, so we multiply that by the number of steps taken.
    //5280 foot in a mile. So we divide 2.2 by 5280.
    double miles = (2.2 * steps) / 5280;
    return miles.round();
  }

  //Method to calculate the calories that have been done.
  int calculateCalories(int steps) {
    //Refrence for average claories burnt per step: https://calculator.academy/steps-to-calories-calculator/#:~:text=In%20general%2C%20most%20people%20burn,by%20your%20age%20and%20weight.
    //The number of calories burnt per step is .04 as a result we multiply the number of steps taken by the calories per step to get total calories.
    double calories = (steps * 0.04);
    return calories.round();
  }
}

//No measurements prompt to tell user to that they cannot save no data.
CupertinoAlertDialog noMeasurements = const CupertinoAlertDialog(
  title: Text("Missing Fields"),
  content: Text(
    "Please save when fields have measurements!",
  ),
);
