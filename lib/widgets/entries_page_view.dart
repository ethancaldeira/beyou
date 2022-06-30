import 'package:audioplayers/audioplayers.dart';
import 'package:beyou/screens/all_chats_screen.dart';
import 'package:beyou/screens/tools_page.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:intl/intl.dart';

import '../utils/emotion_controller.dart';

//This is the widget that is shown to the user for the journal entry page.
Widget journalEntryPage(BuildContext context, String title, String best,
    String proud, String grateful, String improve, Timestamp timestamp)
//We need all these parameters to avoid having to recall the database for the information.
{
  //Need to change the timestamp parameter to DateTime class.
  DateTime date = timestamp.toDate();

  //Now for the page.
  return Padding(
    padding: const EdgeInsets.all(12.0), //Padding avoids overflow errors.
    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          alignment: Alignment.bottomCenter,
          child: Lottie.asset(
              'assets/sunrise.json')), //Using this lottie animation brings the journal to life.
      Column(
        //Need the title of the journal.
        //This is centered.
        children: <Widget>[
          Text(
            title, //Title parametere
            style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold), //Bold for the font as it is a title.
          ),
          //Need a sized box to allow a gap from the title.
          const SizedBox(
            height: 20,
          ),
          //Row contains the date.
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 4.0), //Padding prevents an overflow error.
              child: Text(
                DateFormat('dd/MM/yyyy')
                    .format(date)
                    .toString(), //Takes the date from the parameter and formats it for reading.
              ),
            ),
            const Spacer(), //Spacer so the date and time are on opposite sides of the row.
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 4.0), //Padding prevents an overflow error.
              child: Text(
                DateFormat('HH:mm')
                    .format(date)
                    .toString(), //Takes the date from the parameter and formats it to time for reading.
              ),
            )
          ]),
          //Need another gap for the text to be shown.
          const SizedBox(
            height: 25,
          ),
          //Question about what the best thing that happend to them today.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('The best thing that happened today was: ',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ), //Same title to question used in for when the users add a journal entry.
          const SizedBox(height: 10), //Slight gap, from question to answer.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(best)],
          ), //The users reply to the question about the best thing that happend to them today.
          //This is taken from the parameter best.
          const SizedBox(height: 25), //Gap from one question to another.
          //Question about what they are proud of.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Something I was proud of today: ',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(height: 10), //Slight gap, from question to answer.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(proud)],
          ), //The users reply to the question about what they are proud about.
          //This is taken from the parameter proud.
          const SizedBox(height: 25), //Gap from one question to another.
          //Question about what they want to are grateful for.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('3 Things I am grateful for: ',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(height: 10), //Slight gap, from question to answer.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(grateful)
            ], //The users reply to the question about what they are grateful for.
            //This is taken from the parameter grateful.
          ),
          const SizedBox(height: 25), //Gap from one question to another.
          //Question about what they want to improve.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Something to improve for tommorrow: ',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(height: 10), //Slight gap, from question to answer.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(improve)
            ], //The users reply to the question about what they want to improve.
            //This is taken from the parameter improve.
          ),
        ],
      ),
    ]),
  );
}

//This is the widget that is shown to the user for the image entry page.
Widget imageEntryPage(
    BuildContext context, String title, String imageUrl, Timestamp timestamp)
//We need all these parameters to avoid having to recall the database for the information.
{
  //Need to change the timestamp parameter to DateTime class.
  DateTime date = timestamp.toDate();
  //Show the image, and title.
  return Column(children: <Widget>[
    SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      //Code was adapted from the source: https://stackoverflow.com/questions/53577962/better-way-to-load-images-from-network-flutter
      child: Image.network(imageUrl.toString(), fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
            child: CircularProgressIndicator(
          color: hexStringToColor('471dbc'),
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ));
        //Returns the CircularProgressIndicator as it loads the image.
        //The indicator moves with the progress of the loading of the image.
      }),
    ),
    const SizedBox(
      height: 20,
    ), //Gap from the image to the title.
    Text(
      title, //Parameter title.
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold), //Bold text for the title.
    ), //Title for the image shown using the parameter title.
    const SizedBox(
      height: 20,
    ), //Gap from the title to the time the entry was posted.
    Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 4.0), //Padding prevents an overflow error.
            child: Text(
              DateFormat('dd/MM/yyyy')
                  .format(date)
                  .toString(), //Takes the date from the parameter and formats it for reading.
            ),
          ),
          const Spacer(), //Spacer so the date and time are on opposite sides of the row.
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 4.0), //Padding prevents an overflow error.
            child: Text(
              DateFormat('HH:mm')
                  .format(date)
                  .toString(), //Takes the date from the parameter and formats it to time for reading.
            ),
          )
        ]))
  ]);
}

//This is the widget that is shown to the user for the mood check in page.
Widget moodEntryPage(
  BuildContext context,
  String from,
  int rating,
  String moodToday,
  Timestamp timestamp,
  bool isViewing, //isViewing checks if the entry is a friends entry.
)
//We need all these parameters to avoid having to recall the database for the information.
{
  //Need to change the timestamp parameter to DateTime class.
  DateTime date = timestamp.toDate();
  //Initialised the mood controller object, this controls the animation.
  MoodController moodController = MoodController();
  //Need to re-format the way the mood value is stored in the database.
  String mood = moodToday.replaceAll('\n', ' ');
  //Default rating of the mood.
  double defaultRating = 5.0;
  //Sets the current animation state to 5, which is the maximum state for the animation.
  String currentAnimation = '5+';
  //Need to change the rating from firebase to a double.
  double firebaseRating = rating.toDouble();
  //Want to show the percentage of the mood that the user is feeling.
  //Done by dividing the paramter of value by 5.0 (for the ratings on the slider) and times that by 100 for the percentage.
  double percentageMood = (firebaseRating / 5.0) * 100;
  //Need to know if we need to show the improve mood button to the user.
  bool improveMood = false;

  //The below code is taken from: MoodCheckIn Class, as we need so to set up the animation.
  //Changes the rating if the value is the same as the current rating, which is 5.
  //Reasons for this is we need to set the value of the rating.
  if (defaultRating == firebaseRating) {
  } else {
    //Direction used as the value of _currentAnimation needs to have either + or - in front of it to dicate the current state of animation -
    //of the character, as _currentAnimation is set to '5+'.
    var direction = defaultRating < firebaseRating ? '+' : '-';
    rating = firebaseRating.toInt();
    //Lets the face animation change.
    currentAnimation = '${firebaseRating.round()}$direction';
  }
  //This method returns text instead of the rating, this will be displayed to the user.
  String returnText() {
    //The choice of wording is to ensure that the user does not get in a worse set when logging their mood.
    //Vocabulary used is soft.
    if (rating <= 1.5) {
      return ('Very Down');
    }
    if (rating <= 2.5) {
      return ('Down');
    }
    if (rating <= 3.5) {
      return ('Neutral');
    }
    if (rating <= 4.5) {
      return ('Good');
    }
    if (rating <= 5) {
      return ('Very Good');
    } else {
      return ('');
    }
  }

  //Need to check if today is the same as the parameter date.
  if (DateFormat('dd/MM/yyyy').format(DateTime.now()).toString() ==
      DateFormat('dd/MM/yyyy').format(date).toString()) {
    //If the dates match we can show the improve mood button.
    if (rating < 2.5) {
      //First we need to ensure that the rating of the user is less then 2.5.
      improveMood = true;
    } else {
      //If it is not less then 2.5 then we do not show the button.
      improveMood = false;
    }
  }
  return Column(children: <Widget>[
    //Need to show the face animation.
    SizedBox(
      height: 300,
      width: 300,
      child: FlareActor(
        'assets/happiness_emoji.flr',
        alignment: Alignment.center,
        fit: BoxFit.contain,
        controller: moodController, //Sets the controller.
        animation:
            currentAnimation, //Sets the animation to the rating from the user.
      ),
    ),
    const SizedBox(
      height: 20,
    ), //Gap from the face animtion.
    const Text(
      'Mood Check in',
      style: TextStyle(
          fontSize: 21, fontWeight: FontWeight.bold), //Bold for the title.
    ), //Need the title.
    Padding(
        padding: const EdgeInsets.all(16.0), //Padding avoids an overflow error.
        child: Row(children: [
          //Padding for the text avoids the text being too close together.
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              DateFormat('dd/MM/yyyy')
                  .format(date)
                  .toString(), //Shows the date in a format that is readable.
            ),
          ),
          const Spacer(), //Spacer puts the date and time on opposite sides.
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              DateFormat('HH:mm')
                  .format(date)
                  .toString(), //Shows the date in a format that has it displayed as time.
            ),
          ),
        ])),
    //We then need to show the data from the database.
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(
                top: 20,
                left:
                    20), //Padding avoids the overflow errors and the text overlapping.
            child: Text(
              'Mood today was: ${returnText()}', //Displays the text of the rating the user has given in the entry.
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ))
      ],
    ),
    const SizedBox(height: 20), //Gap to keep text apart.
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(
                left:
                    20), //Padding avoids the overflow errors and the text overlapping.
            child: Text(
              '${returnText()} because of: $from', //Displays the text of the rating the user has given in the entry and the reason why.
              //Done using the parameter from.
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ))
      ],
    ),
    const SizedBox(height: 20),
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(
                left:
                    20), //Padding avoids the overflow errors and the text overlapping.
            child: Text(
              'Mood towards $from: $mood', //Displays the mood towards the reason why the user is feeling down/happy.
              //Done using the parameter mood.
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ))
      ],
    ),
    const SizedBox(height: 20),
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(
                left:
                    20), //Padding avoids the overflow errors and the text overlapping.
            child: Text(
              'Percentage mood for today: ${percentageMood.round()}%', //Displays the mood percentage of the user.
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ))
      ],
    ),
    //Now we need the button for the user.
    //Check if the user is viewing another users entry.

    isViewing == true
        ? improveMood
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 40), //Padding avoids the overflow errors.
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: hexStringToColor(
                          '471dbc')), //Same style as other buttons.
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                const AllChatsPage())); //Sends the user to the chat page, to encourage them to reach out to their friend.
                  },
                  //Text of the button to prompt the user to reach out.
                  child: const Text('Reach Out ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.start),
                ))
            : Container()
        //If it is not a friends entry, we need to check if improve mood is true, this would because the mood is too low.
        : improveMood
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 40), //Padding avoids the overflow errors.
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: hexStringToColor(
                          '471dbc')), //Same style as other buttons.
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                const ToolsPage())); //Sends the users to the tool page if they are feeling down.
                  },
                  //Text prompt to improve the users mood.
                  child: const Text(
                    'Improve Mood',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                ))
            : Container() //If the users mood is not tool low then show an empty container.
  ]);
}

//This widget is for the audio entries.
Widget audioEntryPage(BuildContext context, String title, String audioUrl,
    Timestamp timestamp, AudioPlayer audioPlayer) {
  //We take a parameter of AudioPlayer to ensure that the audio will stop playing when we leave the page.
  //It is initialised in the ViewAnyEntry Class.
  //Need to change the timestamp parameter to DateTime class.
  DateTime date = timestamp.toDate();
  //Checking if the play button is pressed.
  bool isPressed = false;

  //As there is no setState in a widget we need to create a StatefulBuilder that will allow us to change the -
  //state of the bool value isPressed.
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Column(
        mainAxisAlignment:
            MainAxisAlignment.center, //Align the button and text in the centre.
        children: <Widget>[
          //Creates our own button.
          //Code adapted from: https://stackoverflow.com/questions/52786652/how-to-change-the-size-of-floatingactionbutton
          SizedBox(
              width: 200.0,
              height: 200.0,
              child: RawMaterialButton(
                  //Change the colour of the button when it is pressed.
                  fillColor: isPressed
                      ? hexStringToColor('d3c9ef')
                      : hexStringToColor('9780d8'),
                  shape: const CircleBorder(),
                  elevation: 0.0,
                  //Change the icon when it is pressed.
                  child: isPressed ==
                          false //Checks that the button has not been pressed.
                      ? const Icon(
                          Icons.play_arrow,
                          size: 100,
                          color: Colors.white,
                        ) //The play button shown if the button is not pressed.
                      : const Icon(
                          Icons
                              .pause, //Pause button that shows if the play button is pressed.
                          size: 100,
                          color: Colors
                              .black12, //Ensures both icons are the right colour to appear on the button.
                        ),
                  //When the button is pressed we need to do actions.
                  onPressed: () {
                    if (isPressed == false) {
                      //Change the state of the isPressed to true.
                      //Will change the button icon and colour.
                      setState(() {
                        isPressed = true;
                      });

                      //Need to play the audio, we use the given audioUrl parameter to do so.
                      audioPlayer.play(audioUrl, isLocal: false);
                      //When the audio has finished we need to change the button back.
                      audioPlayer.onPlayerCompletion.listen((duration) {
                        //Changes the state of the button back,
                        //-so users can replay the audio.
                        setState(() {
                          isPressed = false;
                        });
                      });
                    }
                    //else if the button has been pressed
                    else {
                      //We need to change the play button to back to the play icon.
                      setState(() {
                        isPressed = false;
                      });
                      //We pause the audio player.
                      audioPlayer.pause();
                    }
                  })),
          const SizedBox(
            height: 60,
          ), //Gap from the button to the title.
          Text(
            title, //Parameter title.
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold), //Bold text for the title.
          ), //Title for the recording shown using the parameter title.
          const SizedBox(
            height: 20,
          ), //Gap from the title to the time the entry was posted.
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 4.0), //Padding prevents an overflow error.
                  child: Text(
                    DateFormat('dd/MM/yyyy')
                        .format(date)
                        .toString(), //Takes the date from the parameter and formats it for reading.
                  ),
                ),
                const Spacer(), //Spacer so the date and time are on opposite sides of the row.
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 4.0), //Padding prevents an overflow error.
                  child: Text(
                    DateFormat('HH:mm')
                        .format(date)
                        .toString(), //Takes the date from the parameter and formats it to time for reading.
                  ),
                )
              ])),
        ]);
  });
}
