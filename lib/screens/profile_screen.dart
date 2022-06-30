import 'dart:convert';
import 'package:beyou/screens/breathing_exercise.dart';
import 'package:beyou/screens/calm_walk.dart';
import 'package:beyou/widgets/nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../services/auth.dart';
import '../utils/character_controller.dart';
import '../utils/check_time.dart';
import '../utils/hex_color.dart';
import '../widgets/entry_preview.dart';
import '../widgets/exercise_cards.dart';
import '../widgets/nav_drawer.dart';

//This class is used to display the users profile page.
class ProfilePage extends StatefulWidget {
  //No parameters are need for this class.
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //We need auth as we are going to query the database.
  final AuthService _auth = AuthService();
  //The global key is needed to display the menu drawer.
  final GlobalKey<ScaffoldState> mainScaffold = GlobalKey<ScaffoldState>();
  //The two bool values are used to change the states of buttons.
  //Checks if the past entries buttons has been clicked.
  bool isPastEntries = true;
  //Checks if the exercise button has been clicked.
  bool isExercise = false;

  @override
  void initState() {
    super.initState();
    //We need to check the users time limit and see if they have gone past it.
    checkTimeLimit(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Key allows the drawer to open.
        key: mainScaffold,
        //Allows us to have a menu drawer on the right hand side of the page, when activated.
        endDrawer: NavDrawer(),
        extendBody: true,
        //Setting the title of the page, keeps the style with the other 4 main pages.
        body: Center(
            //Column acts as a body for the page.
            child: Column(children: <Widget>[
          //A bit different to the other pages as we want a menu button for th user.
          //So a row is used.
          Row(
            children: [
              const Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    top: 60,
                  ),
                  child: Text(
                    "Profile",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  )), //Same style text as the other main pages.
              const Spacer(), //Spacer makes sure both elements of the row are on opposite sides.
              //Menu icon.
              Padding(
                padding: const EdgeInsets.only(
                  right: 12,
                  top: 60,
                ), //Padding needed to stop an overflow error.
                //We need to icon to be clickable so IconButton used.
                child: IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.grey, //Grey to match the text.
                    ),
                    onPressed: () {
                      //When pressed the menu drawer will open, and it will cover some of the existing page
                      mainScaffold.currentState?.openEndDrawer();
                    }),
              ),
            ],
          ),
          //For the rest of the page we need to show content.
          Center(
              //Shows the companion for th user
              child: FutureBuilder(
                  //Runs the method calculate state to see what state the companion should be in.
                  future: calculateState(
                      'this_user'), //Ensuring that its state is set to the current users companion state.
                  builder: (context, snapshot) {
                    //If there is an error in running the method this must be shown to the user.
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
                              height: 300,
                              width: 400,
                              child: RiveAnimation.asset("assets/new_file.riv",
                                  controllers: [
                                    SimpleAnimation(
                                        state), //Sets thier animation to the state we got returned from the method.
                                  ])),
                          //Need to show the message to the user.
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 5,
                                  left: 20,
                                  right: 20,
                                  bottom:
                                      10), //Padding ensures that the message does cause an overflow error.
                              //Text for the message itself.
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: hexStringToColor(
                                        '471dbc')), //Using colour and styling found throughout the app.
                              )),
                        ],
                      );
                    }
                    //If there the data has not yet returned from the method we need to show that it is loading.
                    else {
                      return SizedBox(
                        height: 300,
                        width: 400,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: hexStringToColor(
                                '471dbc'), //Shows CircularProgressIndicator to indicate the data is still being retrieved.
                          )),
                        ),
                      );
                    }
                  })),
          //We need the rows for the diffrent button options
          Row(
            children: [
              //Padding ensures the buttons do not cause an overflow error, and that they are away from the sides of the device.
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                //Past Entries button.
                child: TextButton(
                    child: Text("Past Entries",
                        //Style changes if button is clicked.
                        style: TextStyle(
                            //Font size is increased or decreased if the button is clicked.
                            fontSize: isPastEntries == true ? 18 : 16,
                            decoration: isPastEntries == true
                                //Shows the underlining of the text if the button is clicked.
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            //Ensures the text is the same colour as most of the app.
                            color: hexStringToColor('471dbc'),
                            //Puts the text in bold when the button is clicked.
                            //Shows that the button has been selected.
                            fontWeight: isPastEntries == true
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    //When the button is pressed we need to change the bool values.
                    onPressed: () {
                      setState(() {
                        isPastEntries =
                            true; //Set to true as the past entries button was clicked.
                        isExercise =
                            false; //Set to false as the past entries button was clicked.
                      });
                    }),
              ),
              //Spacer puts each button on opposite ends of the row.
              const Spacer(),
              //Padding ensures the buttons do not cause an overflow error, and that they are away from the sides of the device.
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                //Exercise button.
                child: TextButton(
                    child: Text("Exercises",
                        //Style changes if button is clicked.
                        style: TextStyle(
                            //Font size is increased or decreased if the button is clicked.
                            fontSize: isExercise == true ? 18 : 16,
                            decoration: isExercise == true
                                //Shows the underlining of the text if the button is clicked.
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            //Ensures the text is the same colour as most of the app.
                            color: hexStringToColor('471dbc'),
                            //Puts the text in bold when the button is clicked.
                            //Shows that the button has been selected.
                            fontWeight: isExercise == true
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    //When the button is pressed we need to change the bool values.
                    onPressed: () {
                      setState(() {
                        isPastEntries =
                            false; //Set to false as the exercise button was pressed.
                        isExercise =
                            true; //Set to true as the exercise button was clicked.
                      });
                    }),
              ),
            ],
          ),
          //Checks if the past entries button clicked.
          isPastEntries == true
              //If it is we need to show the past entries.
              ? Expanded(
                  //Querying the database.
                  child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('entries')
                        .where('owner_id',
                            isEqualTo:
                                _auth.getUid()) //Checking for the users posts.
                        .orderBy("date", descending: true) //Ordering by date.
                        .get(),
                    builder: (_, snapshot) {
                      //If there is an error in querying the database this must be shown to the user.
                      if (snapshot.hasError) {
                        return Text('Error = ${snapshot.error}');
                      }
                      //We need to check that the user has posted entries.
                      if (snapshot.hasData) {
                        //Save the data into a variable called entries, as it represents the entries from the user.
                        var docs = snapshot.data?.docs;

                        //It may be the case that the entries are empty.
                        if (docs.toString() == '[]') {
                          //In that case we want to prompt the user.
                          return Center(
                              child: Text(
                            'Please create a journal entry',
                            style: TextStyle(color: hexStringToColor('471dbc')),
                          ));
                        } else {
                          //We need the length of the entries that this user has posted.
                          var len = docs?.length;
                          //To show the entries we need a list view.
                          //We get rid of the auto padding that the ListView uses.
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .removePadding(removeTop: true),
                            child: ListView(
                                children: List.generate(
                                    len!, //Use the length of the query.
                                    //Use our own custom widget to show the entries.
                                    (index) => userEntryPreview(
                                        context,
                                        docs![index]['title'],
                                        docs[index]['date'],
                                        docs[index]['tag'],
                                        docs[index].id,
                                        _auth.getUid(),
                                        false,
                                        true))), //Database data sent to the custom widget so it can display to the users.
                          );
                        }
                      }
                      //If the query has no data we need to show that it is
                      return Center(
                          child: CircularProgressIndicator(
                        color: hexStringToColor('471dbc'),
                      )); //While we wait for the data from the database show the CircularProgressIndicator
                    },
                  ),
                )
              //If the exercise button is pressed we need different content to be shown.
              : isExercise == true
                  //Straight to the ListView, so we remove the auto padding.
                  ? MediaQuery(
                      data:
                          MediaQuery.of(context).removePadding(removeTop: true),
                      //Need to use Flexible to avoid an overflow error.
                      child: Flexible(
                          child: ListView(
                        children: [
                          //Children are the exercise cards.
                          breathingExerciseCard(context), //Breathing exercise.
                          calmWalkExerciseCard(context) //Calm walk exercise.
                        ],
                      )),
                    )
                  : Container() //If neither of the bool values are true return an empty container.
          //This will never be the case.
        ])),
        bottomNavigationBar: NavBar(index: 3)); //Dot bar for navigation.
  }
}
