import 'package:beyou/screens/upload_mood.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../utils/hex_color.dart';
import '../utils/emotion_controller.dart';

//Class to allow users to check in with their mood.
//Code adapted from tutorial: https://www.youtube.com/watch?v=4RHvFVVUWqw
class MoodCheckIn extends StatefulWidget {
  const MoodCheckIn({Key? key}) : super(key: key);
  @override
  _MoodCheckInState createState() => _MoodCheckInState();
}

class _MoodCheckInState extends State<MoodCheckIn> {
  //Set the values needed for the mood check in to work.
  double _rating = 5.0; //Default rating of the mood.
  String currentAnimation =
      '5+'; //Sets the current animation state to 5, which is the maximum state for the animation.
  final MoodController _moodController =
      MoodController(); //Initialised the mood controller object, this controls the animation.

  //This method is for when the slider is moved, in order to get the direction and the correct rating.
  //this method is called when the slider is moved.
  void onMoved(double value) {
    //Returns if the value is the same as the current rating, which is 5.
    //Reasons for this is there has been no change to the animation so no change needed.
    if (_rating == value) return;

    //Changes the state of the animation based on what the value recieved is.
    //Set state method allows for a dynamic resets of the attribute value meaning that the animation will change as the slider moves.
    setState(() {
      //Direction used as the value of _currentAnimation needs to have either + or - in front of it to dicate the current state of animation -
      //of the character, as _currentAnimation is set to '5+'.
      var direction = _rating < value ? '+' : '-';
      _rating = value;
      currentAnimation = '${value.round()}$direction';
    });
  }

  //This method returns text instead of the rating, this will be displayed to the user.
  String returnText() {
    //The choice of wording is to ensure that the user does not get in a worse set when logging their mood.
    //Vocabulary used is soft.
    if (_rating <= 1.5) {
      return ('Very Down');
    }
    if (_rating <= 2.5) {
      return ('Down');
    }
    if (_rating <= 3.5) {
      return ('Neutral');
    }
    if (_rating <= 4.5) {
      return ('Good');
    }
    if (_rating <= 5) {
      return ('Very Good');
    } else {
      return ('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Creating the app bar for the screen. This screen will have a back button if the user decides not to follow with the mood check in.
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation:
                0, //Elevation gives the bar the flat effect, improves the minimalistic feel of the app.
            //Using icon button always the icon to be pressed from the user
            leading: IconButton(
                icon: const Icon(Icons
                    .arrow_back_ios), //Keeping back arrow constant throughout the applicaiton.
                color: hexStringToColor('471dbc'),
                onPressed: () {
                  Navigator.pop(
                      context); //Pops the user back to the previous page which will be homepage.
                })),

        //Creating the main body of the application/
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(top: 10),
                  //Acts as the title of the page as it looks more visibly appealing than having it in the app bar.
                  child: Text(
                    'How are you feeling today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                        color: hexStringToColor('471dbc')),
                  )),
              //Divider between the text and the annimation.
              const SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  //Below SizedBox has the animation inside it.
                  SizedBox(
                    height: 300,
                    width: 300,
                    //FlareActor class allows us to bring the character to live using controllers and setting the animation
                    //which was done earlier.
                    child: FlareActor(
                      'assets/happiness_emoji.flr', //asset locataion of the animation.
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      //Both below values were initialised earlier
                      controller: _moodController,
                      animation: currentAnimation,
                    ),
                  ),
                  //Setting the slider below
                  Slider(
                    //Important to have different colours for the slider and the pointer.
                    thumbColor: hexStringToColor('471dbc'),
                    activeColor: hexStringToColor('9780d8'),
                    autofocus: false,
                    //InactiveColor makes the slider look more like a slider.
                    inactiveColor: Colors.grey,
                    value: _rating,
                    min: 1,
                    max:
                        5, //In line with the values of _rating and _currentAnimation
                    onChanged: onMoved, //Method is called when slider is moved.
                  ),
                  //The live output of text is shown below
                  Text(
                      returnText(), //As this is used in the body of the build method, the text will call this method everytime the setState() method is called.
                      //Therefore updating the text as the slider moves.
                      style: TextStyle(
                          color: hexStringToColor('471dbc'),
                          fontSize: 34,
                          fontWeight: FontWeight.w400)),
                ],
              ),
              const Spacer()
            ],
          ),
        ),
        //Button to move to the next part of the Mood Check In entry.
        floatingActionButton: FloatingActionButton(
            backgroundColor: hexStringToColor(
                '2e3887'), //Using the same colour as the add button on the homepage.
            //Makes the button pop more on the white background.
            child: const Icon(Icons
                .arrow_forward_ios), //Keeping the icon constant with the back arrow.

            //Pressing the button pushes user to another screen to collect more infomation on their mood.
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          //Takes parameter of rating so it is added to the database at the end of the check in.
                          UploadMood(
                            rating: _rating
                                .toInt(), //.toInt() needed as _rating is set to a double as it allows for a more fluid movement of the slider.
                          )));
            }));
  }
}
