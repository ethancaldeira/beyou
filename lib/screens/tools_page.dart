import 'dart:convert';
import 'package:beyou/utils/hex_color.dart';
import 'package:beyou/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../utils/character_controller.dart';
import '../utils/check_time.dart';
import '../widgets/exercise_cards.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({Key? key}) : super(key: key);
  @override
  _CompanionPageState createState() => _CompanionPageState();
}

class _CompanionPageState extends State<ToolsPage> {
  //Need an artboard to reset the animation.
  late Artboard riveArtboard;
  //Set an animation controller that we will give a value to later.
  late SimpleAnimation jumpController;
  //Need to set a isJumping bool to active the jump.
  bool get isJumping => jumpController.isActive;

  //Create an initControllers method to initialise the jump controller.
  void initControllers() {
    jumpController = SimpleAnimation(
      'Jump',
      autoplay: false,
    );
  }

  @override
  void initState() {
    super.initState();
    initControllers(); //Create the jump controller of the companion.
    checkTimeLimit(
        context); //Check that there is still time for the user to be active.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Sets the bottom nav bar, and its index.
      bottomNavigationBar: NavBar(index: 1),
      //Sets the body to a scroll view, this prevents overflow errors from the cards.
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Row needed to put the title as it is a main page.
            Row(children: const [
              Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    top: 60,
                  ),
                  child: Text(
                    "Tools",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  )),
            ]), //Same style as the other main pages.
            //Put the character inside an InkWell so that it can be interactive.
            InkWell(
              //When it is tapped we need to active the bool is jumping.
              onTap: () {
                if (isJumping == false) {
                  setState(() {
                    jumpController.isActive = true;
                  });
                } else {
                  //Code used from: https://github.com/rive-app/rive-flutter/issues/165
                  setState(() {
                    jumpController.reset(); //Resets the jumpController.
                    jumpController.apply(riveArtboard as RuntimeArtboard,
                        0); //Resets the riveArtboard.
                    jumpController.isActive = false; //turns off the animation.
                  });
                }
              },
              //FutureBuilder as we are going to find the state of the companion.
              child: FutureBuilder(
                  future: calculateState(
                      'this_user'), //Instead of querying the database we use the calculate state method, and
                  //- add this_user so the method knows its the current user.
                  builder: (context, snapshot) {
                    //If there is an error in querying the database this must be shown to the user.
                    if (snapshot.hasError) {
                      return Text('Error = ${snapshot.error}');
                    }
                    //Checks if the method has returned data.
                    if (snapshot.hasData) {
                      //Returns a list that we cast to a string.
                      var value = snapshot.data.toString();
                      //We need to jsonDecode the string so we can make it back into a list.
                      var listValue = jsonDecode(value);
                      //Creates a list from the string, and we are instrested in the first value of the list, as that is the state.
                      //We save the state to a state variable.
                      var state = listValue[0];
                      //We are also intrested in the second value as it is the message.
                      //We save the message to a message variable.
                      var message = listValue[1];

                      //Actually need to display the character.
                      return Column(
                        children: [
                          //Sized box for the character.
                          SizedBox(
                              height: 340,
                              width: 400,
                              child: RiveAnimation.asset("assets/new_file.riv",
                                  artboard:
                                      "New Artboard", //Need to access the artboard for when the companion is reset.
                                  onInit: (Artboard artboard) {
                                riveArtboard = artboard;
                              }, //Init needed so that the companion is reset to the idle state after the jump.
                                  controllers: [
                                    SimpleAnimation(
                                        state), //Sets thier animation to the state we got returned from the method.
                                    jumpController, //Also sets the jump animation so the user can press the companion and make it jump.
                                  ])),
                          //Need to show the message to the user.
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5,
                                left: 20,
                                right: 20,
                                bottom:
                                    5), //Padding ensures that the message does cause an overflow error.
                            //Text for the message itself.
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: hexStringToColor(
                                      '471dbc')), //Using colour and styling found throughout the app.
                            ),
                          )
                        ],
                      );
                    }
                    //If there the data has not yet returned from the method we need to show that it is loading.
                    else {
                      return SizedBox(
                        height: 330,
                        width: 400,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: hexStringToColor('471dbc'),
                          )),
                        ),
                      );
                    }
                  }),
            ),
            //Need to show the exercises that the user can select.
            //Cards for the exercises.
            breathingExerciseCard(context), //Breathing exercise
            calmWalkExerciseCard(context) //Calm walk exercise.
          ],
        ),
      ),
    );
  }
}
