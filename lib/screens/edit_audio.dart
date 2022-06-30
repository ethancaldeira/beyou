import 'package:audioplayers/audioplayers.dart';
import 'package:beyou/screens/past_entries.dart';
import 'package:beyou/screens/profile_screen.dart';
import 'package:beyou/screens/view_any_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';

import 'package:intl/intl.dart';

import 'home_screen.dart';

//Class for users to edit a audio entry.
class EditAudioEntry extends StatefulWidget {
  //Need the entryId in order to query the database.
  final String entryId;
  //Following bool values send the user back to the correct page from the ViewAnyEntry Class.
  final bool isHomepage; //Send users back to the homepage.
  final bool isPastJorunal; //Past journal page.
  final bool isProfile; //Or Profile page.

  const EditAudioEntry(
      {Key? key,
      required this.entryId,
      required this.isHomepage,
      required this.isPastJorunal,
      required this.isProfile})
      : super(key: key);
  @override
  _EditAudioEntryState createState() => _EditAudioEntryState();
}

class _EditAudioEntryState extends State<EditAudioEntry> {
  //To get the current users id we need AuthService().
  final AuthService _auth = AuthService();
  //We need variables to add the data from the firebase to.
  late TextEditingController titleData;
  late String audioUrl;
  late DateTime date;
  //Bool value to check if the button is pressed.
  bool isPressed = false;
  //We need to have an audio player so the user can playback the audio.
  AudioPlayer audioPlayer = AudioPlayer();

  //Method deletes the post using the entryId parameter
  void deleteEntry() async {
    //Need to stop the audio playing if the entry is deleted.
    audioPlayer.stop();
    await deleteFromStorage();
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

  //Need a method to delete the file from storage
  deleteFromStorage() async {
    //We need the url for the file.
    await FirebaseFirestore.instance
        .collection('entries')
        .doc(widget.entryId)
        .get()
        .then((value) {
      //Code inspired from: https://stackoverflow.com/questions/45103085/deleting-file-from-firebase-storage-using-url
      //We get the reference to delete the audio.
      Reference storageReference =
          FirebaseStorage.instance.refFromURL(value['audioUrl']);
      //We then delete the file from storage.
      storageReference.delete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same AppBar as the other pages in the app. Keeps design constant.
      appBar: AppBar(
          title: Text(
            'Edit Audio Entry',
            style: TextStyle(color: hexStringToColor("471dbc")),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor("471dbc"),
            onPressed: () {
              //We need to stop the audio playing if we move to the next page.
              audioPlayer.stop();
              //Sends us back to the previous page
              Navigator.pop(context);
            },
          ),
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
          elevation: 0),
      backgroundColor: Colors.white,
      //For the main body we need to use a future builder as we query the database.
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('entries')
            .where(FieldPath.documentId,
                isEqualTo: widget
                    .entryId) //We query the database with the entry id that was taken as a parameter.
            .get(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Text('Error = ${snapshot.error}');
          } //Returns if there is an error when loading the entry data.
          //Checks that the snapshot contains data.
          if (snapshot.hasData) {
            var docs = snapshot.data
                ?.docs; //We need a variable to store the data that we collected from firebase.
            //There should always be data inside the docs variable but in case there is an error, we check -
            //if the variable contents are empty.
            if (docs.toString() == '[]') {
              return const Center(
                  child: Text(
                      'Error loading Audio')); //Returns an error message to the user.
            }
            //If there is data inside the varaible docs we can extract that data.
            else {
              //Setting all the values for the attributes we were initialised as late.
              date = docs![0]['date']
                  .toDate(); //Need to have the toDate() method as the date is stored as a timestamp in firebase.
              titleData = TextEditingController(
                  text: docs[0]['title']
                      .toString()); //Making the title from firebase the exisiting text for the TextEditingController.
              audioUrl = docs[0]['audioUrl']; //Adding the url for the audio.

              //Returning the same screen that is shown in the audioEntryPage widget.
              return Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, //Align the button and text in the centre.
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
                                audioPlayer.onPlayerCompletion
                                    .listen((duration) {
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
                    //Normally would be text but we need it to be a form field so we can fill in the title data.
                    TextFormField(
                        controller:
                            titleData, //The text is the text data from the database.
                        keyboardType: TextInputType.multiline,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(45),
                        ], //Limitting the characters of the title to 45
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        cursorColor: hexStringToColor('471dbc'),
                        decoration: const InputDecoration.collapsed(
                            hintText:
                                'Title')), //Takes the users input for a new title.
                    //Title for the recoding shown using the parameter title.
                    const SizedBox(
                      height: 20,
                    ), //Gap from the title to the time the entry was posted.
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom:
                                    4.0), //Padding prevents an overflow error.
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
                                bottom:
                                    4.0), //Padding prevents an overflow error.
                            child: Text(
                              DateFormat('HH:mm')
                                  .format(date)
                                  .toString(), //Takes the date from the parameter and formats it to time for reading.
                            ),
                          )
                        ])),
                  ]);
            }
          }
          //While we query the database the CircularProgressIndicator is shown.
          return Center(
              child:
                  CircularProgressIndicator(color: hexStringToColor('471dbc')));
        },
      ),
      //Save and update the database button.
      floatingActionButton: FloatingActionButton(
          //Same style as the other save buttons.
          child: const Icon(
            Icons.check,
            semanticLabel: 'Save',
          ),
          backgroundColor: hexStringToColor('2e3887'),
          onPressed: () async {
            //Only need to check that the titleData controller is not empty.
            if (titleData.text == '' || titleData.text == ' ') {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CupertinoAlertDialog(
                      title: Text("Missing Title"),
                      content: Text(
                        "Please fill in the title to save it!",
                      ),
                    );
                  });
            }
            //If the title is not empty then create the data to update firebase.
            else {
              Map<String, dynamic> data = {
                "title": titleData.text,
              };
              //Update the data inside the collection firebase.
              FirebaseFirestore.instance
                  .collection('entries')
                  .doc(widget.entryId)
                  .update(data);
              //Push the user back to to the previous page, without animation, no need to refresh page to see the new changes -
              //as the previous page will re-query the database automatically and find the new changes.
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ViewAnyEntry(
                            userId: _auth.getUid(),
                            entryTag: 'audio',
                            entryId: widget.entryId,
                            isHomepage: widget.isHomepage,
                            isPastJorunal: widget.isPastJorunal,
                            isProfile: widget.isProfile,
                          )));
            }
          }),
    );
  }
}
