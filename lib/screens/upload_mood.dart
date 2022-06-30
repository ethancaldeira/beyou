import 'package:beyou/screens/all_screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../utils/hex_color.dart';

//Class for adding the mood check in to firebase.
class UploadMood extends StatefulWidget {
  //Takes a parameter of rating, this is because this page follows on from the MoodCheckIn class.
  final int rating;
  const UploadMood({Key? key, required this.rating}) : super(key: key);
  @override
  _UploadMoodState createState() => _UploadMoodState();
}

class _UploadMoodState extends State<UploadMood> {
  //Need the id of the user.
  final AuthService _auth = AuthService();
  //Setting the selected indexes both to -1 so that the user will need to pick a Activity and Emotion
  int selectedActivityIndex = -1;
  int selectedEmotionIndex = -1;

  //This method returns a string, it uses the parameter of rating to and displays the corresponding text.
  //This method is taken from the MoodCheckIn class.
  String returnText() {
    //All the strings are lower case as this method is used in a sentence.
    if (widget.rating <= 1.5) {
      return ('very down');
    }
    if (widget.rating <= 2.5) {
      return ('down');
    }
    if (widget.rating <= 3.5) {
      return ('neutral');
    }
    if (widget.rating <= 4.5) {
      return ('good');
    }
    if (widget.rating <= 5) {
      return ('very good');
    } else {
      return (''); //Should never return '' as the rating should be between the outlined ranges.
    }
  }

  //Returns the activity based on the selected index from the user.
  String returnActivity(index) {
    if (index == 0) {
      return ('Work');
    }
    if (index == 1) {
      return ('Study');
    }
    if (index == 2) {
      return ('Friends');
    }
    if (index == 3) {
      return ('Exercise');
    }
    if (index == 4) {
      return ('Social Media');
    } else {
      return (''); //Should never return else as there are only 5 options for the user.
    }
  }

  //Mood is similar to the one above, uses the index number from the user and returns a string.
  //Returns the emotion based on the selected index from the user.
  String returnEmotion(index) {
    if (index == 0) {
      return ('😀\nHappy');
    }
    if (index == 1) {
      return ('😡\nAngry');
    }
    if (index == 2) {
      return ('😟\nWorried');
    }
    if (index == 3) {
      return ('😤\nFrustrated');
    }
    if (index == 4) {
      return ('😔\nSad');
    } else {
      return (''); //Should never return else as there are only 5 options for the user.
    }
  }

  //Displays back to the user.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Same AppBar as the other pages to keep it constant with the app.
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons
                    .close), //Icon close used as it pushes the user back to the homepage.
                //If the user does not want to add the mood check in they can close and will be sent back to the homepage.
                color: hexStringToColor('471dbc'),
                onPressed: () {
                  //No animation when the user is pushed back to the homepage.
                  //Also no need to refresh the Homepage.
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HomePage()));
                })),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    "You're ${returnText()} because?", //Uses the value of the parameter and returns the corresponding string.
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                        color: hexStringToColor('471dbc')),
                  )),
              //Actvitiy Grid.
              Expanded(
                  child: SizedBox(
                child: GridView.count(
                  crossAxisCount:
                      4, //Only 5 options for the user to pick. Starts at 0.
                  //Padding used to prevent overflow on other devices.
                  padding: const EdgeInsets.all(4.0),
                  //Spacing for the options.
                  mainAxisSpacing: 4.0, //Controls the spacing vertically.
                  crossAxisSpacing: 4.0, //Controls the spacing horizontally.
                  //generate 5 items for the GridView.
                  children: List<Widget>.generate(5, (index) {
                    return GridTile(
                        child: Ink(
                      decoration:
                          //Need the border to change when the item is selected.
                          BoxDecoration(
                        border: selectedActivityIndex ==
                                index //If the selectedActivityIndex == index means the item has been picked, so we change the border.
                            ? Border.all(
                                color: hexStringToColor('2e3887'),
                                width:
                                    3.5) //Make border thicker and use same as the save button. Contrasts with the purple text.
                            : Border.all(
                                color: Colors.grey,
                                width:
                                    1.0), //If the item is not selected thin grey border indicates that it is clickable.
                        borderRadius: BorderRadius.circular(
                            30), //Make the items more rounded.
                      ),
                      child:
                          //InkWell allows the GridTile to be clickable.
                          InkWell(
                              customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30)), //Share the same rounded edges as the GridTile.
                              //This shows up with the splash colour so it needs to be the same shape as the GridTile.
                              //On Tap we need code to execute.
                              onTap: () {
                                //We can now set the required values.
                                setState(() {
                                  //Set the value for the activity.
                                  selectedActivityIndex = index;
                                });
                                //User cannot unselect once they have selected an activity, this prevents a potential error, of -
                                //trying  to upload without selecting an activity.
                              },
                              //For the text in the grid we need to show an activity.
                              //Saves us the time of having to write out each activity individually.
                              child: Center(
                                child: Text(
                                  returnActivity(
                                      index), //Returns the activity based on its index.
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign
                                      .center, //Need the text to be centred in the GridTile.
                                ),
                              )),
                    ));
                  }),
                ),
              )),
              //Checks that there has been a selected actvity.
              //Returns the next heading if there has been a selected activity.
              //Prevents the user getting overwhalmed by so many options as the next heading & grid only shows when the user has picked from the first.
              selectedActivityIndex != -1
                  ? Container(
                      padding: const EdgeInsets.only(top: 40, bottom: 10),
                      child: Text(
                        "Your feelings towards ${returnActivity(selectedActivityIndex)}?", //Returns the activity that the user has selected from the first grid.
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            color: hexStringToColor('471dbc')),
                      )) //Same style as the first grid.
                  : Container(),
              //Returns the next grid if there has been a selected activity.
              selectedActivityIndex != -1
                  ? Expanded(
                      child: SizedBox(
                      child: GridView.count(
                        crossAxisCount: 4,
                        padding: const EdgeInsets.all(4.0),
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        //Same as the first grid, 5 options and the same padding and spacing uused.
                        children: List<Widget>.generate(5, (index) {
                          return GridTile(
                              child: Ink(
                            decoration: BoxDecoration(
                              border: selectedEmotionIndex ==
                                      index //This check uses the selectedEmotionIndex as that is the index checker for this grid.
                                  ? Border.all(
                                      color: hexStringToColor('2e3887'),
                                      width: 3.5)
                                  : Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            //The rest of the styling options are the same as the first grid.
                            //Same shape of the GridTiles too.
                            child: InkWell(
                                customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                //Same shape as the first grid.
                                onTap: () {
                                  //Set the value for the selectedEmotionIndex to the index of the selected GridTile.
                                  setState(() {
                                    selectedEmotionIndex = index;
                                  });
                                },
                                //The title for each GirdTile was done by using the same approach as the previous Grid.
                                //However, a new method for returning is needed
                                child: Center(
                                  child: Text(
                                    returnEmotion(
                                        index), //Return the emotion based on the index of the selected GridTile
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ));
                        }),
                      ),
                    ))
                  //If the user has not selected an item from the first Grid display and empty Container.
                  : Container(),
              const Spacer() //Keeps the two grids close.
            ],
          ),
        ),
        //Two floatingActionButtons are used, one to save and the other to go back to the previous stage.
        floatingActionButton: Row(children: [
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: FloatingActionButton(
              backgroundColor: hexStringToColor(
                  '2e3887'), //Same background colour as the other floating action buttons
              heroTag:
                  0, //Hero tag needed as there is more than 1 floating buttons on the page.
              child: const Icon(Icons
                  .arrow_back_ios_new), //Same back icon used as the rest of the app.
              onPressed: () => Navigator.pop(
                  context), //If the back button is pressed pop the user back to the MoodCheckIn page.
            ),
          ),

          const Spacer(), //Spacer puts both buttons on opposite sides of the page.
          FloatingActionButton(
              backgroundColor: hexStringToColor(
                  '2e3887'), //Same background colour as the other floating action buttons
              child: const Center(
                child: Icon(Icons.done),
              ), //Done icon shows that is to finish the mood check in.
              onPressed: () async {
                //Checks to see that an activity has not been selected.
                if (selectedActivityIndex == -1) {
                  //Shows a dialog to the user if an activity has not been selected.
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        //CupertinoAlertDialog to stay with the style of the reset of the app.
                        return const CupertinoAlertDialog(
                          title: Text("Select an Activity"),
                          content: Text(
                            "Please select an activity to record mood check in!",
                          ),
                        );
                      });
                }
                //Then checks to see that an emotion has not been selected.
                else if (selectedEmotionIndex == -1) {
                  //Shows a dialog to the user if an emotion has not been selected.
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        //Similar dialog to the one used for "Select an Activity"
                        return const CupertinoAlertDialog(
                          title: Text("Select an Emotion"),
                          content: Text(
                            "Please select an emotion to record mood check in!",
                          ),
                        );
                      });
                }
                //Else means that the user has selected both emotion and activity.
                else {
                  //Creates the data to upload to the firebase.
                  Map<String, dynamic> data = {
                    "title":
                        'Mood Check In', //Title of the entry is 'Mood Check In'.
                    "owner_id": _auth.getUid(), //Gets current user id.
                    "owner_username": await DatabaseService(uid: _auth.getUid())
                        .retreiveUsername(), //Gets current users username.
                    "mood_today": returnEmotion(
                        selectedEmotionIndex), //Sets the emotion for today.
                    "mood_rating":
                        widget.rating, //Sets the rating from the parameter.
                    'mood_from': returnActivity(
                        selectedActivityIndex), //Sets the activity for today.
                    "date": DateTime.now(), //Sets the time.
                    "formatted_date": DateFormat('dd/MM/yyyy')
                        .format(DateTime.now())
                        .toString(), //Sets the formatted date.
                    "tag": 'mood', //Set the tag to mood as it is a mood entry.
                  };
                  //Uploades to firebase collection entries.
                  FirebaseFirestore.instance.collection('entries').add(data);
                  //Then pushes the user back to the homepage and refreshes so that the user can see the new entry.
                  Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HomePage()))
                      .then((value) => setState(() {}));
                }
              })
        ]));
  }
}
