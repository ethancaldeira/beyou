import 'dart:typed_data';
import 'package:beyou/screens/add_audio.dart';
import 'package:beyou/screens/add_entry.dart';
import 'package:beyou/screens/add_image.dart';
import 'package:beyou/services/auth.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:beyou/widgets/nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/database.dart';
import '../utils/check_time.dart';
import '../widgets/entry_preview.dart';
import 'mood_check_in.dart';

//Class displays the homescreen to the user.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //Need the id of the current user for querying the database.
  final AuthService _auth = AuthService();
  //Create a list of friends, have the list conatin an empty string, this will be removed later.
  List friends = [''];
  //We use datetime a lot in this screen so creating a variable to store the DateTime saves time.
  DateTime now = DateTime.now();
  //Need an imageFile to store the selected image.
  Uint8List? imageFile;
  //Need a value to show that the add button is pressed, so that the colour can change
  bool isPressed = false;
  //Need an animation for the add button.
  late AnimationController buttonAnimation;

  @override
  void initState() {
    super.initState();
    createFriendsList(); //Populate the friend list.
    checkTimeLimit(
        context); //Check the time limit to see user has not suprassed their selected time limit.
    //Set the button animation controller.
    buttonAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    super.dispose();
    buttonAnimation
        .dispose(); //Remove the animation controller when the page is closed.
  }

  //Populate the empty friends list.
  void createFriendsList() async {
    //Create a local list to store all the users friends.
    List userFriends =
        await DatabaseService(uid: _auth.getUid()).retreiveFriends();
    //If the user has friends we can add them to the friends list.
    if (userFriends.isNotEmpty) {
      setState(() {
        //Before adding them we need to remove the empty string.
        friends.remove('');
        //Loop through the local list.
        for (var x in userFriends) {
          friends.add(x); //Add each friends to the list.
        }
      });
    }
  }

  //We need the user to select an image by a prompt.
  //Code adapted from tutorial: https://www.youtube.com/watch?v=BBccK1zTgxw&t=23325s
  //We pass the method context
  selectImagePrompt(BuildContext parentContext) async {
    //Using a SimpleDialog which is different from other pages, as we are able to make the prompt look more like -
    //the design of our application.
    return showDialog(
      context: parentContext, //The context that the method is passed.
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: hexStringToColor(
              '471dbc'), //Adding the colour scheme of our application.
          //Title that for the prompt.
          title: const Text(
            'Upload An Image',
            style: TextStyle(
                color: Colors
                    .white), //White pops when used on the purple background.
            textAlign: TextAlign.center, //Center the text as it is the title.
          ),
          //Now for the options that the user can pick.
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Take a photo',
                  style: TextStyle(color: Colors.white),
                ), //Take a photo option.
                onPressed: () async {
                  //We need to access the camera when taking a photo.
                  Uint8List file = await selectImage(
                      ImageSource.camera); //Select method used.
                  //Once we have a response from the above method we can set the imageFile attribute with a value.
                  setState(() {
                    imageFile =
                        file; //Setting the attribute imageFile with the response from selectImage method.
                  });
                  //Then we need to navigate to the add image page.
                  navigateToAddImage();
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ), //Allows users to upload an image from their gallery.
                onPressed: () async {
                  //We need to access the gallery for this option.
                  Uint8List file = await selectImage(ImageSource.gallery);

                  //Once we have a response from the above method we can set the imageFile attribute with a value.
                  setState(() {
                    imageFile =
                        file; //Setting the attribute imageFile with the response from selectImage method.
                  });
                  //Then we need to navigate to the add image page.
                  navigateToAddImage();
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ), //Option to cancel.
              onPressed: () {
                Navigator.pop(
                    context); //Removes the selectImagePrompt from the screen.
                //No images added.
              },
            )
          ],
        );
      },
    );
  }

//Method to select an image.
//Code adapted from tutorial: https://www.youtube.com/watch?v=BBccK1zTgxw&t=23325s
  selectImage(ImageSource source) async {
    //Using the ImagePicker class.
    final ImagePicker imagePicker = ImagePicker();
    //Create a local variable file to store the result of imagePicker.
    XFile? file = await imagePicker.pickImage(source: source);
    //If the file is not null, we need to return it.
    if (file != null) {
      return await file.readAsBytes(); //Returns the file as a list of bytes.
    }
    print('Null problem file: $file');
    //If the image is null we need to show an erro prompt to the user.
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return errorLoadingImage;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        //Starting with the add button for the homescreen.
        //SpeedDial library allows us to have a button that displays a menu list to the user.
        floatingActionButton: SpeedDial(
          backgroundColor: isPressed
              ? Colors.red
              : hexStringToColor(
                  "2e3887"), //Colour changes when the button is pressed.
          child: Lottie.asset('assets/plusToX.json',
              controller:
                  buttonAnimation), //Setting the animation controller to the buttonAnimation controller.
          onOpen:
              openAddIcon, //When the button is opened we need the animation to move, this method does so.
          onClose:
              closeAddIcon, //When the button is closed we need the animation to move back, this method does so.
          //Having the popup options.
          children: [
            SpeedDialChild(
                child: const Icon(Icons.book),
                label: 'Journal',
                onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AddEntry()))), //Sends the user to the add journal page.
            SpeedDialChild(
                child: const Icon(Icons.emoji_emotions),
                label: 'Mood',
                onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MoodCheckIn()))), //Sends the user to the mood check in page.
            SpeedDialChild(
                child: const Icon(Icons.mic),
                label: 'Audio',
                onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddAudio()))), //Sends the user to the audio recording page.

            SpeedDialChild(
              child: const Icon(Icons.photo),
              label: 'Photo',
              onTap: () => selectImagePrompt(
                  context), //Sends the select image prompt to the user.
            ),
          ],
        ),
        body:
            //Code adapted from: https://stackoverflow.com/questions/62494285/flutter-cool-scroll-to-remove-the-top-and-appears-title-navigation-tab
            //Code help from: https://stackoverflow.com/questions/44493372/is-there-any-definite-list-of-sliver-widgets

            //Allows for the header to be pinned and strech with the top of the page.
            CustomScrollView(
                physics:
                    const BouncingScrollPhysics(), //Has the header bounce with a scroll.
                slivers: [
              //Below is the AppBar that will snap to the top of the page when scolling.
              SliverAppBar(
                  stretch: true, //Strechs when user over scrolls
                  pinned: true, //Pins the header to the top of the page.
                  automaticallyImplyLeading:
                      false, //We do not need a back button.
                  expandedHeight:
                      100.0, //Makes the bar bigger to accomadate the date.
                  backgroundColor: Colors.white,
                  //Properties to set up the app bars.
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const <StretchMode>[
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    //Shows the day, and the date.
                    title: Text(
                      "Today\n${DateFormat('EEEE, MMMM d').format(now).toString()} ",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight
                              .bold), //Bold and grey as it is the page header.
                    ),
                  )),
              //Acts as the body for the app.
              SliverList(
                  //We want a list as we have both the users posts and their friends.
                  delegate: SliverChildBuilderDelegate((c, i) {
                //Querying the database.
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('entries')
                      .where('owner_id',
                          isEqualTo:
                              _auth.getUid()) //Checking for the users posts.
                      .where('formatted_date',
                          isEqualTo:
                              DateFormat('dd/MM/yyyy').format(now).toString())
                      .orderBy("date",
                          descending: true) //Only showing posts from today.
                      .get()
                      .asStream(),
                  builder: (_, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } //If there is an error when querying the database, we need to show that to the user.

                    //If the user there is data from the query we need to extract it.
                    if (snapshot.hasData) {
                      //Set the local variable to save the data too.
                      var docs = snapshot.data?.docs;
                      //Data may be an empty list so we need to check that it is not.
                      if (docs.toString() == '[]') {
                        //If the data is an empty list then we return with a empty container.
                        return Container();
                      }
                      //If there is data from the query we need to return all the posts.
                      else {
                        //Setting the length for when we use a list builder.
                        var len = docs?.length;
                        //Returning the colum that will hold the users posts.
                        return Column(
                          children: [
                            MediaQuery(
                              data: MediaQuery.of(context).removePadding(
                                  removeBottom:
                                      true), //Remove the automatic padding that comes with the ListView.
                              child: ListView(
                                  physics:
                                      const NeverScrollableScrollPhysics(), //We do not need to scroll this ListView as the page scrolls.
                                  shrinkWrap: true, //Needed to show the posts.
                                  children: List.generate(
                                      len!, //Length that we set earlier.
                                      (index) => userEntryPreview(
                                          context,
                                          docs![index]['title'],
                                          docs[index]['date'],
                                          docs[index]['tag'],
                                          docs[index].id,
                                          _auth.getUid(),
                                          false,
                                          false))), //Show the previews of the posts to the user.
                            ),
                          ],
                        );
                      }
                    }
                    return Center(
                        child: CircularProgressIndicator(
                      color: hexStringToColor('471dbc'),
                    )); //While we wait for the data from the database we show a CircularProgressIndicator.
                  },
                );
              },
                      childCount:
                          1)), //As it is a SliverList we need to set the count to just one.
              //New list for the friends posts.
              //Same as the previous widget.
              SliverList(
                  delegate: SliverChildBuilderDelegate((c, i) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('entries')
                      .where('owner_id',
                          whereIn: friends) //Checking for the friends posts.
                      .where('formatted_date',
                          isEqualTo:
                              DateFormat('dd/MM/yyyy').format(now).toString())
                      .orderBy("date",
                          descending: true) //Only showing posts from today.
                      .get()
                      .asStream(),
                  builder: (_, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } //If there is an error when querying the database, we need to show that to the user.

                    //If the user there is data from the query we need to extract it.
                    if (snapshot.hasData) {
                      //Set the local variable to save the data too.
                      var docs = snapshot.data?.docs;
                      //Data may be an empty list so we need to check that it is not.
                      if (docs.toString() == '[]') {
                        //If the data is an empty list then we return with a empty container
                        return Container();
                      }
                      //If there is data from the query we need to return all the posts.
                      else {
                        //Setting the length for when we use a list builder.
                        var len = docs?.length;

                        return MediaQuery(
                          data: MediaQuery.of(context).removePadding(
                              removeTop:
                                  true), //Remove the automatic padding that comes with the ListView.
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom:
                                    85), //Keeps the last post from being completely coverd by the nav bar.
                            child: ListView(
                                physics:
                                    const NeverScrollableScrollPhysics(), //Same as above we do not need to scoll this list view.
                                shrinkWrap: true,
                                children: List.generate(
                                    len!, //Length that we set earlier.
                                    (index) => friendEntryPreview(
                                        docs![index].id,
                                        context,
                                        docs[index]['owner_id'],
                                        docs[index]['title'],
                                        docs[index]['date'],
                                        index,
                                        docs[index]['tag'],
                                        docs[index]['owner_username'],
                                        true))),
                          ), //Show the previews of the friends posts to the user.
                        );
                      }
                    }
                    return Container(); //While we wait for the data from the database do not show the CircularProgressIndicator, or we will get two progress indicators.
                  },
                );
              }, childCount: 1)) //As it is a list we just need to show it once.
            ]),
        bottomNavigationBar: NavBar(index: 0));
  }

  //Moves the button animation when it is clicked on.
  void openAddIcon() {
    setState(() {
      buttonAnimation.forward();
      //Change the colour to red as the button is pressed.
      isPressed = true;
    });
  }

  //Moves the button animation back when it is clicked on.
  void closeAddIcon() {
    setState(() {
      buttonAnimation.reverse();
      //Change the colour back to the blue.
      isPressed = false;
    });
  }

  //Push the user to the add image page.
  void navigateToAddImage() {
    if (imageFile == null) {
      //Prompt to tell the user there was a problem loading the image.
    } else {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AddImageScreen(
                      file: imageFile))); //Using the imageFile variable.
    }
  }

  //CupertinoAlertDialog keeps with the current IOS theme.
  CupertinoAlertDialog errorLoadingImage = const CupertinoAlertDialog(
    //Alerts the user to missing text fields.
    //This prevents any empty data fields being added to the collection in Firebase.
    title: Text("Error"),
    content: Text(
      "We encountered a problem when loading the select image, Please try again!",
    ),
  );
}
