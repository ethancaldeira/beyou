import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:beyou/services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:path_provider/path_provider.dart';

import '../services/firestore_storage.dart';
import '../utils/hex_color.dart';
import 'home_screen.dart';

//This class allows us to add an audio.
//Code was adapted from the following tutorial: https://www.youtube.com/watch?v=z_s3q9wda4g&t=5s
//The count up feature was adapted from: https://medium.flutterdevs.com/stopwatch-timer-in-flutter-70afa58d88e5
class AddAudio extends StatefulWidget {
  const AddAudio({
    Key? key,
  }) : super(key: key);
  @override
  _AddAudioState createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  //We need _auth for the user id of the user when we upload to the firebase storage.
  final AuthService _auth = AuthService();
  //Creating a TextEditingController to take the title input from the user.
  TextEditingController titleData = TextEditingController();
  //Timer and countUp allow us to count the duration of the recording.
  Timer? timer;
  //Need duration for the counter.
  Duration duration = const Duration();

  //Need to know if the audio is playing.
  bool isPlaying = false;
  //Need to know if we are uploading to firebase and firebase storage.
  bool isUploading = false;
  //Need bool value for when we finish recording.
  bool isRecorded = false;
  //Need to know if we are recording.
  bool isRecording = false;
  //Need an audioPlayer to playback recorded audio.
  AudioPlayer audioPlayer = AudioPlayer();
  //Need to store the file somewhere before we send it to firebase.
  late String audioFilePath;
  //Need an audio recorder to record the audio.
  late FlutterAudioRecorder2 audioRecorder;

  @override
  void initState() {
    super.initState();
  }

  //Method resets the counting, so resets the numbers increasing.
  void resetCounting() {
    //Resets the counting
    setState(() {
      duration = const Duration(minutes: 0);
    });
  }

  //Starts the counting
  void startCounting() {
    //Increases the time shown by 1 second.
    timer = Timer.periodic(const Duration(seconds: 1), (_) => countUpTime());
  }

  void stopCounting() {
    resetCounting(); //We need to reset the counting.
    setState(() {
      timer?.cancel();
    }); //And cancel the timer so it is not counting in th background.
  }

  void countUpTime() {
    setState(() {
      //Then we add 1 to the seconds as it counts up this way.
      final seconds = duration.inSeconds + 1;
      //If the recording goes past 10 minutes we need to stop it.
      if (seconds > 600) {
        setState(() {
          isRecording = false; //Stopping the recording.
          isRecorded = true; //Setting the recorded to true.
          timer?.cancel(); //Cancel the timer
        });
      } else {
        //If it has not surpassed 10 minutes we can keep going.
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Same style AppBar as the rest of the app.
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('Record Audio',
                style: TextStyle(color: hexStringToColor('471dbc'))),
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: hexStringToColor('471dbc'),
                onPressed: () {
                  //Need to stop the audioPlayer if the user is leaving the page.
                  audioPlayer.stop();
                  //Need to stop the counting if the user leaves the page.
                  stopCounting();
                  //Sends the user back to the homepage, and refreshes it.
                  Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HomePage()))
                      .then((value) => setState(() => {}));
                })),
        body: Center(
          //Need to check if the recording is done.
          child: isRecorded
              //If it is done we need to check if we are uploading to the database.
              ? isUploading
                  //If we are uploading we need to show a CircularProgressIndicator.
                  ? Center(
                      child: CircularProgressIndicator(
                      color: hexStringToColor('471dbc'),
                    ))
                  //If we are not uploading it means the recording is done.
                  : Column(
                      //Column starts in the centre of the page with playback options.
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ///Creates our own button.
                        //Code adapted from: https://stackoverflow.com/questions/52786652/how-to-change-the-size-of-floatingactionbutton
                        SizedBox(
                            width: 200.0,
                            height: 200.0,
                            child: RawMaterialButton(
                                //Change the colour of the button when it is pressed.
                                fillColor: isPlaying
                                    ? hexStringToColor('d3c9ef')
                                    : hexStringToColor('9780d8'),
                                shape: const CircleBorder(),
                                elevation: 0.0,
                                //Change the icon when it is pressed.
                                child: !isPlaying //Checks that the button has not been pressed.
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
                                //When our custon button is pressed we need to play the audio.
                                onPressed: () {
                                  //We call our play audio method.
                                  playAudio();
                                })),
                        //We then need to have the text form for the title, so padding keeps the button and text seprate.
                        Padding(
                          padding: const EdgeInsets.only(
                              top:
                                  25.0), //Padding to prevent an overflow error.
                          child: TextFormField(
                              controller:
                                  titleData, //Sets the controller to the TextEditingController initialised earlier.
                              keyboardType: TextInputType
                                  .multiline, //Sets the keyboard type.
                              maxLines: 1, //Max lines to only one.
                              textAlign: TextAlign
                                  .center, //Have the text appear in the center of the.
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                    45), //Limits the title to only 45 characters.
                              ],
                              style: const TextStyle(
                                  fontSize:
                                      25), //Setting the size of the title.
                              cursorColor: hexStringToColor(
                                  '471dbc'), //Set cursor to the main colour of the app for consistency.
                              decoration: const InputDecoration.collapsed(
                                  hintText:
                                      'Give this recording a title')), //Have a hint text for the user.
                        )
                      ],
                    )
              //We then want to check if we are currently recording.
              : isRecording
                  //If we are recording we want to show the count up time.
                  ? Column(mainAxisAlignment: MainAxisAlignment.center,
                      //So we call the widget that builds the count up.
                      children: [
                          buildCount(),
                        ])
                  //If we are not recording we need to give options to start.
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Use our custom style of box.
                        SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: RawMaterialButton(
                                //We do not want any colours for this button.
                                shape: const CircleBorder(),
                                elevation: 0.0,
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 100,
                                  color: Colors.red, //Red for the play button.
                                ),
                                //When they have pressed play we need to start the recording.
                                onPressed: () {
                                  //We call the record button method that will start recording if we are not already.
                                  recordButton();
                                })),

                        const SizedBox(
                          height: 15,
                        ), //We need a gap from the text and the button.
                        //Need to inform the user of what to do.
                        Text('Press play to record',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: hexStringToColor('471dbc'),
                                fontSize: 26))
                      ],
                    ),
        ),
        //We want to use a variety of floatingActionButtons.
        floatingActionButton:
            //Check if we are reocridng to show the stop button.
            isRecording
                ? FloatingActionButton(
                    //Same colour as the add entries button on the homepage.
                    backgroundColor: hexStringToColor('2e3887'),
                    //Icon button not required just the icon.
                    child: const Icon(
                      Icons.stop,
                      semanticLabel: 'Stop Recording',
                    ), //Icon shows the stop icon.
                    onPressed: () {
                      //We call the record button method that will stip recording if we are recording already.
                      recordButton();
                    })
                //We then check if we have recorded.
                : isRecorded
                    //We want options if we have recorded.
                    ? Row(children: [
                        //Replay button pressed once the user has finished recording.
                        //Lets them re-record their audio.
                        Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  25.0), //Need padding so the button is visible
                          child: FloatingActionButton(
                            //Need heroTag as there are more than one floatingActionButtons.
                            heroTag: 1,
                            //Same colour as the add entries button on the homepage.
                            backgroundColor: hexStringToColor('2e3887'),
                            //Icon button not required just the icon.
                            child: const Icon(
                              Icons.replay,
                              semanticLabel: 'Replay',
                            ), //Replay for icon.
                            onPressed: () {
                              //Method to re record the audio from the user.
                              reRecordAudio();
                            },
                          ),
                        ),
                        const Spacer(), //Puts the buttons on opposite sides of the page.
                        //Save button pressed once the user has finished recording.
                        FloatingActionButton(
                          //Same colour as the add entries button on the homepage.
                          backgroundColor: hexStringToColor('2e3887'),
                          //Done icon to show the user to finish their recording.
                          child: const Icon(
                            Icons.done,
                            semanticLabel: 'Save',
                          ),
                          onPressed: () {
                            //We need to check if the title has any data before we save.
                            if (titleData.text == "" || titleData.text == " ") {
                              //Dialog shown to user to inform them to add a title.
                              //Prevents an recording being uploaded to firebase without a title.
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    //CupertinoAlertDialog used as all the dialogs within the app are CupertinoAlertDialog.
                                    return const CupertinoAlertDialog(
                                      title: Text("Missing Title"),
                                      content: Text(
                                        "Please give this recording a title to save it!",
                                      ),
                                    );
                                  });
                            }
                            //If there is not a problem with the title we can add the audio to firebase.
                            else {
                              //Method saves the audio to firebase, and firebase storage.
                              audioToFirebase();
                            }
                          },
                        )
                      ])
                    : Container());
  }

  //Method to save the audio to firebase.
  Future<void> audioToFirebase() async {
    //We set the isUploading to turn so the progress indicator can be shown.
    setState(() {
      isUploading = true;
    });
    //Then we need to try upload to Firebase Storage.
    try {
      //We set up the Reference to the storage.
      Reference ref = FirebaseStorage.instance
          .ref('audio_entries')
          .child(_auth.getUid())
          .child(audioFilePath.substring(
              audioFilePath.lastIndexOf('/'), audioFilePath.length));
      //Using code from addImageFirestore inside the FirestoreConnection class.
      //To upload the audio it needs to be in the correct format.
      UploadTask uploadTask = ref.putFile(File(audioFilePath));
      //Need to wait for the new format before we can upload.
      TaskSnapshot snapshot = await uploadTask;
      //Then we need the URL for the audio location in storage.
      String audioUrl = await snapshot.ref.getDownloadURL();
      //Then we can addAudioEntry to firebase using the FirestoreConnection class.
      FirestoreConnection().addAudioEntry(audioUrl, titleData.text);
    }
    //Need to catch any errors.
    catch (error) {
      //Formatt errorrs so they can be shown to the user.
      String formatError = error.toString().replaceAll(RegExp('\\[.*?\\]'), '');
      //Show dialog pop up for any errors when uploading to firebase.
      showDialog(
          context: context,
          builder: (BuildContext context) {
            //CupertinoAlertDialog used as all the dialogs within the app are CupertinoAlertDialog.
            return CupertinoAlertDialog(
              title: const Text("Error Uploading"),
              content: Text(
                "An error occured while uploading your audio. Please try again! \n\n Hint: $formatError", //Show the user the error in a formatted style.
              ),
            );
          });
    }
    //If there is no error we need to change isUploading as we have uploaded.
     finally {
      setState(() {
        isUploading = false;
        navigateHomePage(); //Then we navigate the user back to the home page.
      });
    }
  }

  //Allows us to restart the audio recording.
  void reRecordAudio() {
    audioPlayer
        .stop(); //Need to make sure that the recorded audio is not playing.
    setState(() {
      //Reset back to start recording button.
      isRecorded = false;
    });
  }

  //Method for the record button.
  Future<void> recordButton() async {
    //Need to check if the audio recorder is recording.
    //This if will run when the press the stop button.
    if (isRecording) {
      //If it is recording then we need to stop the recording.
      audioRecorder
          .stop(); //Need to make sure that the recorded audio is not playing.
      stopCounting(); //Stop the count up.
      isRecording = false; //We are no longer recording.
      isRecorded = true; //We have recorded.
    } else {
      //This starts the recording.
      startCounting(); //Start the counting.
      isRecorded = false; //We have not recorded yet.
      isRecording = true; //We are recording now though.
      //Need to start the recording.
      await startAudioRecording();
    }
    //Refresh page.
    setState(() {});
  }

  //Method for audio playback
  void playAudio() {
    //Check that we are not currently playing.
    if (!isPlaying) {
      //If we are not we can start.
      isPlaying = true;
      //Play the audio.
      audioPlayer.play(audioFilePath, isLocal: true);
      //When the audio is finished we need to reset the play button.
      audioPlayer.onPlayerCompletion.listen((duration) {
        //Resetting the play button.
        setState(() {
          isPlaying = false;
        });
      });
    }
    //If we are playing we need to pause.
    else {
      audioPlayer.pause(); //Pause the audio.
      isPlaying = false; //Change the button back.
    }
    setState(() {}); //Refresh the page.
  }

  //Method to start the audio recording.
  Future<void> startAudioRecording() async {
    //We need to check that we have recording permission from the user.
    final bool? recordingPermission =
        await FlutterAudioRecorder2.hasPermissions;
    //code used from: https://www.youtube.com/watch?v=z_s3q9wda4g&t=5s
    if (recordingPermission ?? false) {
      //Sets up the Directory for an audio file.
      Directory directory = await getApplicationDocumentsDirectory();
      //Setting the parth for the audio file.
      String audiopath = directory.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.aac';
      //Now we can create the flutter audio recorder, as we have a filepath for the file.
      audioRecorder =
          FlutterAudioRecorder2(audiopath, audioFormat: AudioFormat.AAC);
      //We wait for the audioRecorder to be initialised.
      await audioRecorder.initialized;
      //Then we start the recorder.
      audioRecorder.start();
      //Set the value for the late attribute audioFilePath.
      audioFilePath = audiopath;
      setState(() {}); //Refresh the page.
    } else {
      setState(() {
        isRecording = false;
      });

      /*
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text('Please enable recording permission'))));*/
      showDialog(
          context: context,
          builder: (BuildContext context) {
            //CupertinoAlertDialog used as all the dialogs within the app are CupertinoAlertDialog.
            return const CupertinoAlertDialog(
              title: Text("Enable LOL Mircophone"),
              content: Text(
                "Please enable mircophone permission, in order to record an audio entry! Once you have enabled permissions please try again!. ", //Show the user the error in a formatted style.
              ),
            );
          });
      //Prompt to enable the mirophone permissions.
    }
  }

  Widget buildCounting({required String time, required String timeType}) {
    //Returns the Column that contains the numbers.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius:
                  BorderRadius.circular(20)), //Set the counting outline to red
          //Red for recording.
          child: Text(
            time, //the counting time.
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 50), //Size 50 so the number is large.
          ),
        ),
        //Then we a small gap to the headers of the time, or the time type, either minutes or seconds.
        const SizedBox(
          height: 24,
        ),
        Text(timeType,
            style: const TextStyle(
                color: Colors
                    .red)), //Red for the font colour as it matches the red boxs for the numbers.
      ],
    );
  }

  //We need a method that can update the time.
  Widget buildCount() {
    //Changes the duration into string.
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    //Need minutes.
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    //Need seconds.
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    //Row for the time type so the headers for each section of the time.
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildCounting(time: minutes, timeType: 'MINUTES'),
      const SizedBox(
        width: 8, //Need a gap between the headers.
      ),
      buildCounting(time: seconds, timeType: 'SECONDS'),
    ]);
  }

//Method to navigate user to the homepage once the audio is uploaded.
  navigateHomePage() {
    //Refreshes the homepage to show any changes the added audio entry.
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage())).then((value) => setState(() {}));
  }
}
