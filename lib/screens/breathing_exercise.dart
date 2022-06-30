import 'dart:async';
import 'package:beyou/screens/tools_page.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../utils/hex_color.dart';

//Class for the breathing exercise for the user.
class BreathingExercise extends StatefulWidget {
  const BreathingExercise({Key? key}) : super(key: key);

  @override
  _BreathingExerciseState createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with SingleTickerProviderStateMixin {
  //Sets the attributes for the class.
  bool isBreathing = false;
  bool isHold = false;
  bool isExhaling = false;
  bool isPressed = false;

  //Sets the attributes that are used for the timer, which should count up.
  bool counting = true;
  int numberCounter = 0;
  Duration duration = const Duration();
  Timer? timer;
  static const countingDuration = Duration(minutes: 0);
  //Sets the AnimationController for the lottie animation.
  late AnimationController controller;
  //Sets the animation controllers for the character.
  late SimpleAnimation characterIdle;
  late SimpleAnimation characterBreathing;
  //Need an artboard to reset the animation.
  late Artboard riveArtboard;

  //Inside the init state the controllers are initialised
  @override
  void initState() {
    super.initState();
    //Controllers for the character
    _initControllers();
    //Controllers for the lottie animation
    _initLottieController();
  }

  //Method to initialise the characters animations
  void _initControllers() {
    characterIdle = SimpleAnimation(
        'Idle'); //Idle will be the main animation while the user is not doing the breathing exercise.
    characterBreathing = SimpleAnimation('Breathing',
        //autoplay needs to be false as it will mean when the button is pressed the animation will take place.
        autoplay:
            false); //Breathing will be the animation of the character while the user is doing the exercise.
  }

  //Method to initialise the lottie animation.
  void _initLottieController() {
    controller = AnimationController(
      vsync: this,
      //setting the duration of the animation to 21 seconds should match the breathing time.
      duration: const Duration(seconds: 21),
    )..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
      }); //Adding addListener allows for the animation to repeat once it finishes.
  }

//Method to start the character breathing.
  void toggleBreathing() {
    //Checks if the user is following the exercise.
    if (isBreathing == false) {
      setState(() {
        characterBreathing.isActive =
            true; //Sets the breathing animation to active.
      });
    } else {
      //Code used from: https://github.com/rive-app/rive-flutter/issues/165
      setState(() {
        characterBreathing.reset(); //Resets the characterBreathing animation.
        characterBreathing.apply(
            riveArtboard as RuntimeArtboard, 0); //Resets the riveArtboard.
        characterBreathing.isActive = false; //turns off the animation.
      });
    }
  }

  //Method resets the counting, so resets the numbers increasing.
  void resetCounting() {
    setState(() => duration = countingDuration);
  }

  //Method Sets the breathing out coutdown which is displayed to the user.
  void setBreathOut() {
    setState(() => duration = const Duration(seconds: 9));
  }

  //Method has the count up starting at 1 second.
  void setHold() {
    setState(() => duration = const Duration(seconds: 1));
  }

  //Starts the timer for counting.
  void startCountingTimer() {
    isBreathing = true;

    //Increases the timer by one second and calls the method countUp() while it does so.
    timer = Timer.periodic(const Duration(seconds: 1), (_) => countUp());
  }

  //Stops the timer for counting.
  void stopTimer() {
    //Resets the counting so it goes back to 0.
    resetCounting();
    //Sets breathing to false, so the time and animation disappears.
    isBreathing = false;
    //Sets the timer to cancel.
    setState(() => timer?.cancel());
  }

  //Method that counts up and displays to the user.
  void countUp() {
    //Adds or subtracts seconds from the duration.
    final addSeconds = counting ? 1 : -1;

    //Below starts the 4-7-8 Breathing exercise for the user.

    //This if statements is for the inhaling, this needs to last 4 seconds.
    if (numberCounter <= 3 && isHold == false && isExhaling == false) {
      //numberCounter starts at 0 so four seconds would be equal to 3.

      setState(() {
        //Keeps adding 1 to the number counter.
        numberCounter = numberCounter + 1;

        //Vibrates as the count up is happening.
        HapticFeedback.vibrate();
        //Sets both bool vaules to false as breath out needs to be displayed to the user.
        isHold = false;
        isExhaling = false;
        //Increments the seconds.
        final seconds = duration.inSeconds + addSeconds;
        //If the seconds are less than 0 than the timer needs to be cancelled.
        if (seconds < 0) {
          timer?.cancel();
        } else {
          //Otherwise the duration needs to be updated with the value seconds.
          duration = Duration(seconds: seconds);
        }
      });
    }
    //This else statement is for the hold breath part of the exercise.
    else {
      //Checks to see if the numberCounter is at 4 and the user is not being told to hold their breathe.
      if (numberCounter == 4 && isHold == false) {
        //Sets isHold to true so that HOLD can be displayed to the user.
        isHold = true;
        //Resets the count up to 1 second.
        setHold();
        //Reset numberCounter to 0 so there can be a count up.
        numberCounter = 0;
      } else {
        //Inside the below if statement the count up for the hold part of the exercise occurs.
        if (numberCounter < 8 && isHold == true) {
          setState(() {
            isHold = true;
            //Increments the numberCounter.
            numberCounter = numberCounter + 1;
            //Increments the count up shown to the user.
            final seconds = duration.inSeconds + addSeconds;
            //Same statement from earlier checks if the seconds are less than 0
            if (seconds < 0) {
              //Cancels the timer if they are.
              timer?.cancel();
            } else {
              //Sets the duration to the value of seconds.
              duration = Duration(seconds: seconds);
            }
          });
        }
        //Checks if the number counter has reach 7 as the user should only hold their breath for 7 seconds.
        if (numberCounter == 7 && isHold == true) {
          //Bool value to false as user is no longer holding their breath.
          isHold = false;
          //Bool value to true so the user is shown the BREATH OUT text.
          isExhaling = true;
          //setBreathOut sets the duration to 8 seconds so the user can be shown the 8 seconds count down for exhaling.
          setBreathOut();
        }
        //The below if statement starts the exhaling
        if (numberCounter > 0 && isExhaling == true) {
          setState(() {
            //Keeps isHold to false.
            isHold = false;
            //Keeps isExhaling true as BREATH OUT needs to be shown to the user.
            isExhaling = true;

            int seconds = numberCounter;
            //Counts down by subtracting a second from the duration.
            seconds = duration.inSeconds - addSeconds;
            //Vibrates per second of the exhaling, has a heavy impact for the user to feel the exhaling.
            HapticFeedback.heavyImpact();
            //Checks that the seconds have not reached below 0 yet.
            if (seconds < 0) {
              //When they do the user is no longer exhaling but inhaling again.
              isHold = false;
              isExhaling = false;
              //Set the number counter to 0 so the timer can be reset.
              numberCounter = 0;
              //Reset the timer.
              resetCounting();
            } else {
              //Otherwise have the duration be equal to the current value of seconds.
              duration = Duration(seconds: seconds);
            }
          });
        }
      }
    }
  }

  //Method is called as the page is left, ensures that the controller is disposed of.
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          //Same App bar style as other pages within the app.
          AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text('Slow Breathing',
                  style: TextStyle(color: hexStringToColor('471dbc'))),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: hexStringToColor('471dbc'),
                  onPressed: () {
                    //Send users back to the tool page.
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ToolsPage()));
                  })),
      body: Center(
        child: Column(
          children: [
            //Character inside a small sized box, so that there is space for the lottie animation.
            SizedBox(
                height: 250,
                width: 400,
                child: RiveAnimation.asset(
                  "assets/new_file.riv",
                  //sets the controllers of the character to Idle, and breathing.
                  //Breathing has autoplay disabled so that the character only breathes when the user is breathing.
                  controllers: [characterIdle, characterBreathing],
                  artboard:
                      "New Artboard", //Need to access the artboard for when the companion is reset.
                  onInit: (Artboard artboard) {
                    riveArtboard = artboard;
                  }, //Init needed so that the companion is reset to the idle state after the breathing.
                )),

            //Have space between the character and the breathing graphics.
            const SizedBox(
              height: 50,
            ),
            //Checks if the user is following the exercise.
            !isBreathing
                ? Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text('Press and Hold Button to begin',
                        style: TextStyle(
                            color: hexStringToColor('471dbc'), fontSize: 24),
                        textAlign: TextAlign.center),
                  ) //If they are not have text shown to the user.
                : Center(
                    child: Container(
                        child:
                            showCounting())), //If they are breathing show the counting.
          ],
        ),
      ),
      //floatingActionButton is the play button for the exercise, so it is located in the middle of the page.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          //Using Gesture detector allows us to only show the breahting graphics if the user holds the button.
          GestureDetector(
        //When they start the long press have the necessary methods run.
        onLongPressStart: (_) {
          setState(() {
            //toggleBreathing starts the breathing for the character
            toggleBreathing();
            //Setting the numberCounter to 0 means each time the user presses the breathing will be reset.
            numberCounter = 0;
            //Allows for a change of the button graphics.
            isPressed = true;
            //Displays the breathing graphics.
            startCountingTimer();
          });
        },
        onLongPressEnd: (_) {
          setState(() {
            //toggleBreathing also stops the breathing for the character
            toggleBreathing();
            //The lottie controller for the lottie animation needs to be reset so that when the user presses again. the animation starts over.
            controller.reset();
            //Has the counting graphic and lottie animation, disapper.
            isBreathing = false;
            //Resets the button appear back to the play button.
            isPressed = false;
            //Sets all the so that when the user re-presses the breathing will start again.
            isHold = false;
            isExhaling = false;
            numberCounter = 0;
          });
          stopTimer(); //Stops the timer entirely so that the timer is not going on in the background.
        },
        child:
            //Have the FloatingActionButton as the child of the gesture dectector.
            FloatingActionButton(
                //Have the background colour change if the user is holding the button.
                backgroundColor: isPressed == false
                    ? hexStringToColor('2e3887')
                    : Colors.grey,
                child: isPressed == false
                    ? const Icon(Icons
                        .play_arrow) //Play for if the user is not holding the button.
                    : const Icon(Icons
                        .air_sharp), //Air icon while they are holding to show that the breathing graphics is happening.
                onPressed: (() async {})),
      ),
    );
  }

  //Widget to show the user the breathing graphics.
  //Takes the parameter of timeCounter which shows the count up or down and indicator
  //Indicator is to show the part of the exercise the user is doing, e.g holding, exhaling or inhaling.
  Widget buildBreathingGraphics(
      {required String timeCounter, required String indicator}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Stack allows the time and the lottie animation to overlap one another.
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
                height: 300,
                child: Lottie.asset(
                  'assets/breathing-flower.json',
                  controller:
                      controller, //Sets the controller to the one initialised earlier.
                  onLoaded:
                      (composition) //When the animation is loaded have the controller start.
                      {
                    controller.forward();
                  },
                )),
            //Have the time text overlap over the lottie animation.
            Text(
              timeCounter,
              style: TextStyle(
                  fontWeight: FontWeight
                      .bold, //Bold to stand out over the lottie animation.
                  color: hexStringToColor(
                      '471dbc'), //Same colour as the main colour used in the app, as it stands out ontop of the animation.
                  fontSize:
                      75 //Large text size so that the user can see it over the animation.
                  ),
            ),
          ],
        ),
        //The indictor shown below the both the time counter and animation.
        Text(indicator,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hexStringToColor('471dbc'),
                fontSize: 21)),
      ],
    );
  }

  //showCounting method is where the graphics and the timer come together
  Widget showCounting() {
    //Create a method that takes a interger and returns it as a string.
    String intToString(int n) => n.toString();
    //Creates the countNumber shown to the user, by taking the duration and returning it as a string.
    final countNumber = intToString(duration.inSeconds.remainder(60));
    //Return the buildBreathingGraphics as it displays to the user.
    return buildBreathingGraphics(
        timeCounter: countNumber,
        indicator: isHold == false //Checks isHold is False.
            ? isExhaling ==
                    true //If it is false it checks if isExhaling is true.
                ? 'BREATHE OUT' //Shows BREATH OUT if isExhaling is true.
                : 'BREATHE IN' //Shows BREATH IN if isExhaling is false.
            : 'HOLD' //Shows HOLD if isHold is equal to true.
        );
  }
}
