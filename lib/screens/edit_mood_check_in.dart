import 'package:beyou/screens/past_entries.dart';
import 'package:beyou/screens/profile_screen.dart';
import 'package:beyou/screens/view_any_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';
import '../utils/emotion_controller.dart';
import 'home_screen.dart';

//This Class allows users to edit their mood check ins.
class EditMoodCheckIn extends StatefulWidget {
  final String
      entryId; //Need to entry id for when we collect the data from the entry.
  //Following bool values send the user back to the correct page from the ViewAnyEntry Class.
  final bool isHomepage; //Send users back to the homepage.
  final bool isPastJorunal; //Past journal page.
  final bool isProfile; //Or Profile page.

  const EditMoodCheckIn(
      {Key? key,
      required this.entryId,
      required this.isHomepage,
      required this.isPastJorunal,
      required this.isProfile})
      : super(key: key);

  @override
  _EditMoodCheckInState createState() => _EditMoodCheckInState();
}

class _EditMoodCheckInState extends State<EditMoodCheckIn> {
  final AuthService _auth = AuthService();

  //Need the data from the data to be saved to variables.
  late DateTime date;
  late int moodRating;
  late String moodFrom;
  late String moodToday;

  //Checks if the slider has been set already.
  bool setAlready = false;

  //To have the smiley animation move we need an animation controller for it.
  final MoodController _moodController = MoodController();

  //Have the same attributes as the MoodCheckIn & UploadMood Classes.
  //This is because this page uses both of those pages in one single scrollable view.
  double _rating = 5.0;
  String currentAnimation = '5+';
  int selectedActivityIndex = -1;
  int selectedEmotionIndex = -1;
  //Need a variable to set the document from after querying the database.
  late String docId;

  //This method returns a string, it uses the parameter of rating to and displays the corresponding text.
  //This method is taken from the MoodCheckIn class.
  String returnTextLowerCase() {
    if (_rating <= 1.5) {
      return ('very down');
    }
    if (_rating <= 2.5) {
      return ('down');
    }
    if (_rating <= 3.5) {
      return ('neutral');
    }
    if (_rating <= 4.5) {
      return ('good');
    }
    if (_rating <= 5) {
      return ('very good');
    } else {
      return ('');
    }
  }

  //This method returns a string, it uses the parameter of rating to and displays the corresponding text. Returns in uppercase.
  //This method is taken from the MoodCheckIn class.
  String returnText() {
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

  //This method is taken from the UploadMood class.
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
      return ('');
    }
  }

  //This method is taken from the UploadMood class.
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
      return ('');
    }
  }

  //This method is inspired from the UploadMood class.
  //It takes the string from the database and returns the index of that string for the activity grid.
  int returnActivityIndex(index) {
    if (index == 'Work') {
      return (0);
    }
    if (index == 'Study') {
      return (1);
    }
    if (index == 'Friends') {
      return (2);
    }
    if (index == 'Exercise') {
      return (3);
    }
    if (index == 'Social Media') {
      return (4);
    } else {
      return -1;
    }
  }

  //This method is inspired from the UploadMood class.
  //It takes the string from the database and returns the  of that string for the emotion grid.
  int returnEmotionIndex(index) {
    if (index == '😀\nHappy') {
      return (0);
    }
    if (index == '😡\nAngry') {
      return (1);
    }
    if (index == '😟\nWorried') {
      return (2);
    }
    if (index == '😤\nFrustrated') {
      return (3);
    }
    if (index == '😔\nSad') {
      return (4);
    } else {
      return -1;
    }
  }

  //Change values method changes the values of the attributes based on what it read from firebase.

  void changeValues(int newRating, String moodFrom, String moodToday) async {
    //Checks if the values have already been set.
    if (setAlready == false) {
      //If the have not bool value to true as the value are about to be set.
      setAlready = true;
      //Checks if the _rating is the same as the newRating if so there is no need to change the animation and slider.
      if (_rating == newRating) {
        setState(() {
          //So just change the selected indexes for the activity and for emotion grids.
          selectedActivityIndex = returnActivityIndex(
              moodFrom); //Uses the string to index methods to return the index.
          selectedEmotionIndex = returnEmotionIndex(moodToday);
        });
      }
      //If its the ratings are not the same we need to change the slider and animation
      else {
        setState(() {
          //Create local value changing the int from the database into a double.
          double value = newRating.toDouble();
          //Changing the slider is the same approach as that used in MoodCheckIn class.
          var direction = _rating < value ? '+' : '-';
          _rating = value;
          //We change the animation.
          currentAnimation = '${value.round()}$direction';
          //Set the selected indexes for the activity and for emotion grids.
          selectedActivityIndex = returnActivityIndex(
              moodFrom); //Uses the string to index methods to return the index.
          selectedEmotionIndex = returnEmotionIndex(moodToday);
        });
      }
    } //else do nothing, this is because this method is called in the build widget so would constant keep running if we did not use the setAlready bool.
    else {}
  }

  //Same method as the one from the MoodCheckIn class
  void onMoved(double value) {
    if (_rating == value) return;
    setState(() {
      var direction = _rating < value ? '+' : '-';
      _rating = value;
      currentAnimation = '${value.round()}$direction';
    });
  }

  //Method deletes the post using the entryId parameter
  void deleteEntry() {
    //Calls to Firestore and deletes the entry, with id equal to the parameter entryId.
    FirebaseFirestore.instance
        .collection('entries')
        .doc(widget.entryId)
        .delete();
    //Then we need to send the user back two pages, as we cannot send them back to the ViewAnyEntry class, as the entry is now gone.
    //Using the parameter bool values we can send the user to the correct page and refresh that page.
    if (widget.isHomepage == true) {
      //Sending user to homepage and refreshing it.
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage())).then((value) => setState(() {}));
    } else if (widget.isPastJorunal == true) {
      //Sending user to past journal page and refreshing it.
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PastEntriesPage())).then((value) => setState(() {}));
    } else if (widget.isProfile == true) {
      //Sending user to profile and refreshing it.
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfilePage())).then((value) => setState(() {}));
    }
  }

  //Display to the user,
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same style app bar as the other app bar within the app.
      appBar: AppBar(
        title: Text('Edit Mood Rating',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: hexStringToColor('471dbc'))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor('471dbc'),
            onPressed: () {
              Navigator.pop(
                  context); //Pops the user back to page they came from.
            }),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: hexStringToColor("471dbc"),
            //Same style as the back arrow.
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                        //Asks the user if they are sure they want to delete this entry.
                        title: const Text("Delete this entry?"),
                        content: const Text(
                          "Are you sure you want to delete this entry? This action cannot be undone.",
                        ),
                        //Buttons for either yes or no.
                        actions: [
                          CupertinoDialogAction(
                              child: const Text(
                                "Yes",
                              ),
                              //If they select yes.
                              onPressed: () {
                                //The dialog is then popped off the screen and the delete method is called.
                                Navigator.of(context).pop();
                                //Delete entry method is then called, to delete the method.
                                deleteEntry();
                              }),
                          //If the users select no.
                          CupertinoDialogAction(
                              child: const Text("No"),
                              onPressed: () {
                                //The dialog is popped off the screen and the entry is not deleted.
                                Navigator.of(context).pop();
                              })
                        ]);
                  });
            },
          ),
        ],
      ),
      //We want to hold a lot of options for the user so a SingleChildScrollView changes the body into a scrollable page.
      //This way we can have the outputs of the MoodCheckIn class and the UploadMood class on one page.
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          //FutureBuilder as we are going to query the database.
          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('entries')
                  .where(FieldPath.documentId,
                      isEqualTo: widget
                          .entryId) //Query the exact entry by using the entries id.
                  .get(),
              builder: (_, snapshot) {
                //May encounter an error if so we need that to be displayed to the user.
                //This avoids an app crash.
                if (snapshot.hasError) {
                  return Text('Error = ${snapshot.error}');
                }
                //This will always be true but we need to still check if the snapshot has data.
                if (snapshot.hasData) {
                  var docs = snapshot.data?.docs;
                  if (docs.toString() == '[]') {
                    //Again this will not happen but there may be an error when loading the Mood Check so it is -
                    //better to display to the user. Also means we can show a progress indicator while loading.
                    return const Center(
                        child: Text('Found No Mood Check In To Edit'));
                  } else {
                    //Setting all the attributes to the data from the query.
                    date = docs![0]['date'].toDate();
                    moodRating = docs[0]['mood_rating'];
                    moodFrom = docs[0]['mood_from'];
                    moodToday = docs[0]['mood_today'];
                    //Set the document id.
                    docId = docs[0].reference.id.toString();
                    //Change the values, allows us to change the values from the string we have.
                    //Changes the animation and the grid indexes for both activity and emotion.
                    changeValues(moodRating, moodFrom, moodToday);

                    //Returns the MoodCheckIn and the UploadMood displays on one single view.
                    //All the code here is used from MoodCheckIn and UploadMood classes so no need to comment all of it.
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: [
                              //Only change is the smaller sized box to house the animation.
                              SizedBox(
                                height: 200,
                                width: 200,
                                child: FlareActor(
                                  'assets/happiness_emoji.flr',
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                  controller: _moodController,
                                  animation: currentAnimation,
                                ),
                              ),
                              Slider(
                                thumbColor: hexStringToColor('471dbc'),
                                activeColor: hexStringToColor('9780d8'),
                                autofocus: false,
                                inactiveColor: Colors.grey,
                                value: _rating,
                                min: 1,
                                max: 5,
                                onChanged: onMoved,
                              ),
                              Text(returnText(),
                                  style: TextStyle(
                                      color: hexStringToColor('471dbc'),
                                      fontSize: 34,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          SizedBox(
                            height: 800,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                    padding: const EdgeInsets.only(
                                        top: 75, bottom: 10),
                                    child: Text(
                                      "You're ${returnTextLowerCase()} because?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 24,
                                          color: hexStringToColor('471dbc')),
                                    )),
                                Expanded(
                                    child: SizedBox(
                                  child: GridView.count(
                                    physics:
                                        const NeverScrollableScrollPhysics(), //Needed so that the user can scroll the whole page
                                    crossAxisCount: 4,
                                    childAspectRatio: 1.0,
                                    padding: const EdgeInsets.all(4.0),
                                    mainAxisSpacing: 4.0,
                                    crossAxisSpacing: 4.0,
                                    children: List<Widget>.generate(5, (index) {
                                      return GridTile(
                                          child: Ink(
                                        decoration: BoxDecoration(
                                          border: selectedActivityIndex == index
                                              ? Border.all(
                                                  color: hexStringToColor(
                                                      '2e3887'),
                                                  width: 3.5)
                                              : Border.all(
                                                  color: Colors.grey,
                                                  width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: InkWell(
                                            customBorder:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                            onTap: () {
                                              setState(() {
                                                selectedActivityIndex = index;
                                              });
                                            },
                                            child: Center(
                                              child: Text(
                                                returnActivity(index),
                                                style: const TextStyle(
                                                    fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            )),
                                      ));
                                    }),
                                  ),
                                )),
                                selectedActivityIndex != -1
                                    ? Container(
                                        padding: const EdgeInsets.only(
                                            top: 15, bottom: 10),
                                        child: Text(
                                          "Your feelings towards ${returnActivity(selectedActivityIndex)}?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 24,
                                              color:
                                                  hexStringToColor('471dbc')),
                                        ))
                                    : Container(),
                                selectedActivityIndex != -1
                                    ? Expanded(
                                        child: SizedBox(
                                        child: GridView.count(
                                          physics:
                                              const NeverScrollableScrollPhysics(), //Needed so that the user can scroll the whole page
                                          crossAxisCount: 4,
                                          childAspectRatio: 1.0,
                                          padding: const EdgeInsets.all(4.0),
                                          mainAxisSpacing: 4.0,
                                          crossAxisSpacing: 4.0,
                                          children:
                                              List<Widget>.generate(5, (index) {
                                            return GridTile(
                                                child: Ink(
                                              decoration: BoxDecoration(
                                                border: selectedEmotionIndex ==
                                                        index
                                                    ? Border.all(
                                                        color: hexStringToColor(
                                                            '2e3887'),
                                                        width: 3.5)
                                                    : Border.all(
                                                        color: Colors.grey,
                                                        width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                shape: BoxShape.rectangle,
                                              ),
                                              child: InkWell(
                                                  customBorder:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                  onTap: () {
                                                    setState(() {
                                                      selectedEmotionIndex =
                                                          index;
                                                    });
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      returnEmotion(index),
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )),
                                            ));
                                          }),
                                        ),
                                      ))
                                    : Container(),
                                const Spacer() //Keeps the two grids close.
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                //Returns a CircularProgressIndicator while snapshot has no data. So while it loads the data.
                return const Center(child: CircularProgressIndicator());
              }),
        ]),
      ),

      //The floatingActionButton pushes the new changes to firebase.
      floatingActionButton: FloatingActionButton(
          backgroundColor: hexStringToColor('2e3887'),
          child: const Icon(Icons.done),
          onPressed: () async {
            //Should never be the case but if there has been a glitch we need to ensure that the user selects an activity.
            if (selectedActivityIndex == -1) {
              //Same dialog as the one from UploadMood class.
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CupertinoAlertDialog(
                      title: Text("Select an Activity"),
                      content: Text(
                        "Please select an activity to record mood check in!",
                      ),
                    );
                  });
            }
            //Again should never be the case but if there has been a glitch we need to ensure that the user selects an emotion.
            else if (selectedEmotionIndex == -1) {
              //Same dialog as the one from UploadMood class.
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CupertinoAlertDialog(
                      title: Text("Select a Emotion"),
                      content: Text(
                        "Please select an emotion to record mood check in!",
                      ),
                    );
                  });
            }
            //If there is no glitch there is data for all the needed values.
            else {
              //Create the data that we want to update.
              Map<String, dynamic> data = {
                "mood_today": returnEmotion(
                    selectedEmotionIndex), //Returns the string like used in UploadMood Class.
                "mood_rating": (_rating.round())
                    .toInt(), //Round the rating and make it an int.
                'mood_from': returnActivity(
                    selectedActivityIndex), //Returns the string like used in UploadMood Class.
                //No need to update any other data as only 3 things are able to be changed with the mood check in.
              };
              //Update the new data to the correct document in firebase.
              FirebaseFirestore.instance
                  .collection('entries')
                  .doc(docId) //This ensure the correct document is updated.
                  .update(data);

              //Then push the user back to the view entry page.
              //Refresh the page while pushing so they can see the changes.
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ViewAnyEntry(
                            userId: _auth.getUid(),
                            entryId: widget.entryId,
                            entryTag: 'mood',
                            isHomepage: widget.isHomepage,
                            isPastJorunal: widget.isPastJorunal,
                            isProfile: widget.isProfile,
                          ))).then((value) => setState(() {}));
            }
          }),
    );
  }
}
