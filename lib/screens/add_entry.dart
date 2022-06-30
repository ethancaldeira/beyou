import 'package:beyou/screens/all_screens.dart';
import 'package:beyou/services/database.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth.dart';

//Class to add journal entry.
class AddEntry extends StatefulWidget {
  const AddEntry({Key? key}) : super(key: key);
  @override
  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final AuthService _auth =
      AuthService(); //Provides ID for the user so that the data can be pushed to firebase.

  //Values below are not final as they will be edited by the user.
  TextEditingController titleData =
      TextEditingController(); //Text editor for the title.
  TextEditingController bestThingData =
      TextEditingController(); //Text editor for the the best thing in their day.
  TextEditingController proudThingData =
      TextEditingController(); //Text editor for the something they were proud of in their day.
  TextEditingController gratefulData =
      TextEditingController(); //Text editor for the things they were grateful for from their day.
  TextEditingController improveData =
      TextEditingController(); //Text editor for the something they need to improve.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Creating the app bar
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors
                .transparent, //Transparent for the background so the page looks more like a page from a journal.
            //If the bar would be white it would take away from the immersive experience of the page.
            //Does mean that time and battery for IOS is obstructed but adds to the immersion of the page.

            //Keeping the style the same throughout the app with the back icon button.
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: hexStringToColor(
                    '471dbc'), //Same colour as the rest of the app.
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); //Pops the user back to the homepage.
              },
            )),
        //Safe Area used so that the inputted text does not cause an overflow error should the user write too much for the sreen.
        body: SafeArea(
          child:
              //Padding also used for the container to prevenet the text causing overflow area.
              Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Stack(
              children: <Widget>[
                //Media Query clips the automatic padding that is added to a ListView.
                MediaQuery(
                  data: MediaQuery.of(context).removePadding(removeTop: true),
                  child: ListView(
                    children: <Widget>[
                      //Sets the theme of the page to transparent, this also makes the input fields look more appealing than without setting a theme.
                      Theme(
                        data: ThemeData(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          //Removes the automatic inputDecoration theme to all the input fields.
                          inputDecorationTheme: const InputDecorationTheme(
                              border: InputBorder.none),
                        ),
                        child:
                            //Column conatins all the text form fields
                            Column(
                          children: <Widget>[
                            //The title text form, contains padding to seprate the title from all the other fields
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: TextFormField(
                                //Assigns the title data
                                controller: titleData,
                                //Sets the keyboardtype, or type of input it is.
                                keyboardType: TextInputType.multiline,
                                //Setting the min and max lines the input can go.
                                minLines: 1,
                                maxLines: 2,
                                //Changes the cursor colour to match with the application.
                                cursorColor: hexStringToColor('471dbc'),
                                //Sets the hint text to bold as it is the title.
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                //Aligning the text in the center of the page as it is the title.
                                textAlign: TextAlign.center,
                                //Sets the hint text value, this will help users know what input is wanted
                                decoration: const InputDecoration(
                                  hintText: 'Title of Journal Entry',
                                ),
                                //Sets a limit to the length of the title to 45 characters
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(45),
                                ],
                              ),
                            ),

                            //First TextFormField for the journal.
                            TextFormField(
                              //Setting the type and controller for this TextFormField.
                              controller:
                                  bestThingData, //Looking for the user to type what the best thing about their day was.
                              keyboardType: TextInputType.multiline,
                              //MaxLines does need to be set to null, as this makes the text wrap into lines.
                              //Setting null as the value as there is no limit on the number of lines the user can write.
                              maxLines: null,
                              //Seeting the colour to keep constant with the theme, this will be the same for each following TextFormFields
                              cursorColor: hexStringToColor('471dbc'),
                              //Setting hint text
                              decoration: const InputDecoration.collapsed(
                                  hintText:
                                      'Best thing that happend to you today?'),
                              //No input limit for this form field.
                            ),
                            const SizedBox(
                                height:
                                    30), //Provides a gap between the first input and the second. Gap stays constant no matter how many lines the text is.
                            //Second TextFormField for the journal.
                            TextFormField(
                              //Assigning a diffrernt controller and hint value is the only difference.
                              controller:
                                  proudThingData, //Looking for user to refelct on what made them proud in their day.
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorColor: hexStringToColor('471dbc'),
                              //Hint text set below.
                              decoration: const InputDecoration.collapsed(
                                  hintText:
                                      'Something you were proud of today?'),
                            ),
                            const SizedBox(
                                height: 30), //Same sized box to act as a gap.
                            TextFormField(
                              controller:
                                  gratefulData, //For this input the user needs to list 3 things they are grateful for from their day.
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorColor: hexStringToColor('471dbc'),
                              //Hint text set below.
                              decoration: const InputDecoration.collapsed(
                                  hintText: '3 things you are grateful for?'),
                            ),
                            const SizedBox(
                                height: 30), //Same sized box to act as a gap.
                            TextFormField(
                              controller:
                                  improveData, //This input asks the user what they can improve on from their day.
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorColor: hexStringToColor('471dbc'),
                              //Hint text set below.
                              decoration: const InputDecoration.collapsed(
                                  hintText:
                                      'Something to improve for tommorrow?'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        //Save button pressed once the user has entered the values.
        floatingActionButton: FloatingActionButton(
            //Same colour as the add entries button on the homepage.
            backgroundColor: hexStringToColor('2e3887'),
            //Icon button not required just the icon.
            child: const Icon(
              Icons.check,
              semanticLabel: 'Save',
            ),
            onPressed: () async {
              //If statement to check that all the text fields have values and there are no empty fields.
              //The || means or.
              if (titleData.text == '' ||
                  bestThingData.text == '' ||
                  proudThingData.text == '' ||
                  gratefulData.text == '' ||
                  improveData.text == '') {
                //returns a dialog to inform users to that a field or all fields of data are empty.
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return noText;
                    });
              } else {
                //Creates a dictionary of the data.
                Map<String, dynamic> data = {
                  "owner_id": _auth.getUid(), //collects the ID of the user
                  "owner_username": await DatabaseService(uid: _auth.getUid())
                      .retreiveUsername(), //Retrieves the usersname.
                  "title":
                      titleData.text, //Sets the title to inputted title data.
                  "best_thing": bestThingData
                      .text, //Sets the best_thing field to inputted data.
                  "proud_of": proudThingData
                      .text, //Sets the proud_of field to the right inputted data.
                  "grateful": gratefulData
                      .text, //Sets the grateful field to the right inputted data.
                  "improve": improveData
                      .text, //Sets the improve field to  the right inputted data.
                  "date": DateTime.now(), //Sets the date to now
                  "formatted_date": DateFormat('dd/MM/yyyy')
                      .format(DateTime.now())
                      .toString(), //Formats the data so that it can be read from later.
                  "tag": 'journal', //Sets the tag of the entry to journal.
                };
                FirebaseFirestore.instance
                    .collection('entries')
                    .add(data); //Adds the all the data into the entries field

                //Then pushes the user back to the homepage where the page is refershed to see the new added entry.
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HomePage())).then((value) => setState(
                    () {})); //SetState() Refreshes the page when the user is pushed to it.
              }
            }));
  }

//CupertinoAlertDialog keeps with the current IOS theme.
  CupertinoAlertDialog noText = const CupertinoAlertDialog(
    //Alerts the user to missing text fields.
    //This prevents any empty data fields being added to the collection in Firebase.
    title: Text("Missing Text"),
    content: Text(
      "Please fill in the all sections of the journal to save it!",
    ),
  );
}
