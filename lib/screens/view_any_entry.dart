import 'package:audioplayers/audioplayers.dart';
import 'package:beyou/screens/all_screens.dart';
import 'package:beyou/screens/edit_audio.dart';
import 'package:beyou/screens/edit_mood_check_in.dart';
import 'package:beyou/screens/edit_entry.dart';
import 'package:beyou/screens/edit_image_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';
import '../widgets/entries_page_view.dart';

//Class is used to display the any entry in detail.
class ViewAnyEntry extends StatefulWidget {
  //Need these parameters for the class to show the correct data/
  final String entryId; //Id for the post entry.
  final String userId; //The users id who posted the entry.
  final String entryTag; //And the entry tag.
  //Taking these bool values so that the user is be pushed back to the correct page.
  final bool isHomepage; //Either the homepage.
  final bool isPastJorunal; //Past journal page.
  final bool isProfile; //Or Profile page.

  const ViewAnyEntry(
      {Key? key,
      required this.entryId,
      required this.userId,
      required this.entryTag,
      required this.isHomepage,
      required this.isPastJorunal,
      required this.isProfile})
      : super(key: key);

  @override
  _ViewAnyEntryState createState() => _ViewAnyEntryState();
}

class _ViewAnyEntryState extends State<ViewAnyEntry> {
  //Need auth so we can query the database.
  final AuthService _auth = AuthService();
  //Checking if we are viewing the current users post.
  //Set to false automatically
  bool isCurrentUser = false;
  //Need to set up an audio player for when it is an audio entry.
  final AudioPlayer audioPlayer = AudioPlayer();

  //Method to check if we are current user.
  void checkCurrentUser() {
    //Checks the given userId against the current users id.
    if (widget.userId == _auth.getUid()) {
      setState(() {
        //If they match we change isCurrentUser to true as we are the current user.
        isCurrentUser = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //Method run in the initState to check if we are current user.
    checkCurrentUser();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    //We stop the audio play when we dispose the class.
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar in the same style as the others inside the app.
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor("471dbc"),
            onPressed: () {
              //When back we need to figure out which page to send the user to.
              //If the came from the homepage.
              if (widget.isHomepage == true) {
                //We send them to the homepage and refresh the page as they may have edited the entry.
                Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const HomePage()))
                    .then((value) => setState(() => {}));
              }
              //If they came from the past journal page.
              else if (widget.isPastJorunal == true) {
                //We send them to the PastEntriesPage and refresh.
                Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const PastEntriesPage()))
                    .then((value) => setState(() => {}));
              }
              //If they came from the profile page.
              else if (widget.isProfile == true) {
                //We send them to the ProfilePage and refresh.
                Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProfilePage()))
                    .then((value) => setState(() => {}));
              }
              //If they did not come from either of the three they came from the friends page.
              else {
                //So we just Navigator.pop back.
                Navigator.pop(context);
              }
            },
          ),
          elevation: 0,
          //We need an edit button if the post belongs to current user.
          actions: [
            //We check if the post is the current users.
            isCurrentUser == true
                //If it is we show the edit button.
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    color: hexStringToColor(
                        "471dbc"), //Same style as the other buttons in the AppBars.
                    //Now when they want to edit the entry we need to know which entry it is.
                    onPressed: () {
                      //Checking if the entry is a journal entry.
                      if (widget.entryTag == 'journal') {
                        //If it is we send them to EditEntry page for the journals.
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        EditEntry(
                                          entryId: widget.entryId,
                                          isHomepage: widget.isHomepage,
                                          isPastJorunal: widget.isPastJorunal,
                                          isProfile: widget.isProfile,
                                        )));
                      }
                      //Checking if the entry is a mood entry.
                      else if (widget.entryTag == 'mood') {
                        //If it is we send them to EditMoodCheckIn page for the mood check ins.
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        EditMoodCheckIn(
                                          entryId: widget.entryId,
                                          isHomepage: widget.isHomepage,
                                          isPastJorunal: widget.isPastJorunal,
                                          isProfile: widget.isProfile,
                                        )));
                      }
                      //Checking if the entry is a photo entry.
                      else if (widget.entryTag == 'photo') {
                        //If it is we send them to EditImageEntry page for images.
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        EditImageEntry(
                                          entryId: widget.entryId,
                                          isHomepage: widget.isHomepage,
                                          isPastJorunal: widget.isPastJorunal,
                                          isProfile: widget.isProfile,
                                        )));
                      } else if (widget.entryTag == 'audio') {
                        //If it is we send them to EditAudioEntry page for audio entries.
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        EditAudioEntry(
                                          entryId: widget.entryId,
                                          isHomepage: widget.isHomepage,
                                          isPastJorunal: widget.isPastJorunal,
                                          isProfile: widget.isProfile,
                                        )));
                      }
                    },
                  )
                : Container() //If the entry is not the current users they should not be able to edit it.
            //So return an empty Container.
          ]),

      backgroundColor: Colors.white,
      //We need to display the information for the entry from the user.
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        //So we need to query the database.
        future: FirebaseFirestore.instance
            .collection('entries') //Checks the entries collection.
            .where(FieldPath.documentId,
                isEqualTo: widget
                    .entryId) //Matches the doc id with the entry id, so we show the right data.
            .get(),
        builder: (_, snapshot) {
          //We check if there was an error loading the data.
          if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); //We return the erro to the user.
          }
          //If there is no error we get the data.
          if (snapshot.hasData) {
            //Save the data to variable called docs.
            var docs = snapshot.data?.docs;
            //Check if the data is empty. This should never happen but we check incase.
            //To access this page the user needs to have clicked on an entry so this will never happen.
            //But if there was a delay and an entry was not properly deleted it may.

            if (docs.toString() == '[]') {
              return const Center(
                  child: Text(
                      'Problem with loading the data from database')); //If it is empty then there was a problem so display that to user.
            }
            //If the entry is not empty we can check its data.
            else {
              //Saving the tag of the post.
              var tag = docs![0]['tag'];
              //Checking to see if the tag is a journal.
              if (tag == 'journal') {
                //Returns the journalEntryPage with the needed information if it is a journal.
                return journalEntryPage(
                    context,
                    docs[0]['title'],
                    docs[0]['best_thing'],
                    docs[0]['proud_of'],
                    docs[0]['grateful'],
                    docs[0]['improve'],
                    docs[0]['date']);
              }
              //Checking to see if the tag is a mood entry.
              else if (tag == 'mood') {
                //First we need to check if the entry is a friends entry, as the bool value will be different.
                if (docs[0]['owner_id'] == _auth.getUid()) {
                  //Returns the moodEntryPage with the needed information if it is a mood entry.
                  return moodEntryPage(
                      context,
                      docs[0]['mood_from'],
                      docs[0]['mood_rating'],
                      docs[0]['mood_today'],
                      docs[0]['date'],
                      false);
                } else {
                  //Returns the moodEntryPage with the needed information if it is a mood entry.
                  //Bool set to true as the user is viewing a friends mood check in.
                  return moodEntryPage(
                      context,
                      docs[0]['mood_from'],
                      docs[0]['mood_rating'],
                      docs[0]['mood_today'],
                      docs[0]['date'],
                      true);
                }
              }
              //Checking to see if the tag is a image entry.
              else if (tag == 'photo') {
                //Returns the imageEntryPage with the needed information if it is an image entry.
                return imageEntryPage(context, docs[0]['title'],
                    docs[0]['imageUrl'], docs[0]['date']);
              } //Checking to see if the tag is an audio entry.
              else if (tag == 'audio') {
                //Returns the audioEntryPage with the needed information if it is an audio entry.
                return audioEntryPage(context, docs[0]['title'],
                    docs[0]['audioUrl'], docs[0]['date'], audioPlayer);
              }
            }
          }
          //If there is no data from the database, or while we wait for the data.
          return Center(
              child: CircularProgressIndicator(
            color: hexStringToColor('471dbc'),
          )); //We show the CircularProgressIndicator in the apps colour.
        },
      ),
    );
  }
}
