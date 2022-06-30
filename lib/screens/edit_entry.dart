import 'package:beyou/screens/all_screens.dart';
import 'package:beyou/screens/view_any_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';
import 'package:intl/intl.dart';

//This class is to edit any journal entries.
class EditEntry extends StatefulWidget {
  //Need the entryId in order to query the database.
  final String entryId;
  //Following bool values send the user back to the correct page from the ViewAnyEntry Class.
  final bool isHomepage; //Send users back to the homepage.
  final bool isPastJorunal; //Past journal page.
  final bool isProfile; //Or Profile page.

  const EditEntry({
    Key? key,
    required this.entryId,
    required this.isHomepage,
    required this.isPastJorunal,
    required this.isProfile,
  }) : super(key: key);

  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  final AuthService _auth = AuthService();
  //We need TextEditingController for the inputs that we will take from the user.
  late TextEditingController titleData;
  late TextEditingController bestThingData;
  late TextEditingController proudThingData;
  late TextEditingController gratefulData;
  late TextEditingController improveData;
  //Date will be taken from the database entry so we need to store it in a variable.
  late DateTime date;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same AppBar as the other pages. Keeps design constant with the rest of the app.
      appBar: AppBar(
          title: Text(
            'Edit Entry',
            style: TextStyle(color: hexStringToColor("471dbc")),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor("471dbc"),
            onPressed: () {
              Navigator.pop(context); //Sends users back to the previous page.
            },
          ),
          //Actions to delete the entry.
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
            return Text('Error: ${snapshot.error}');
          } //Returns if there is an error when loading the entry data.
          //Checks that the snapshot contains data.
          if (snapshot.hasData) {
            var docs = snapshot
                .data?.docs; //Creates a variable to store the snapshot data.
            //Should never happen but we check that there is data inside the variable docs.
            if (docs.toString() == '[]') {
              return const Center(
                  child: Text(
                      'Error Loading Jornal ')); //Returns an error message to the user.
            }
            //If there is data inside the varaible docs we can extract that data.
            else {
              //Setting all the values for the attributes we were initialised as late.
              date = docs![0]['date']
                  .toDate(); //Have to change the date from timestamp into DateTime.
              titleData = TextEditingController(
                  text: docs[0]['title']
                      .toString()); //Setting the exisitng values as the text for the TextEditingController.
              //This is repeated for all the input areas.
              bestThingData =
                  TextEditingController(text: docs[0]['best_thing'].toString());
              proudThingData =
                  TextEditingController(text: docs[0]['proud_of'].toString());
              gratefulData =
                  TextEditingController(text: docs[0]['grateful'].toString());
              improveData =
                  TextEditingController(text: docs[0]['improve'].toString());
              //Below is the same code as AddEntry class so no need to comment in depth.
              //The only changes is adding the exisitng values from the firebase database into the input fields.
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Shows the same animation as the view entry page.
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: Lottie.asset('assets/sunrise.json')),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: TextFormField(
                                  controller: titleData,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  //Limiting the characters of the input to 45, the same as the AddEntry class.
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(45),
                                  ],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  cursorColor: hexStringToColor('471dbc'),
                                  //Hint text needs to be shown if the user deletes the title.
                                  decoration: const InputDecoration.collapsed(
                                      hintText: 'Title')),
                            ),
                            //Date and the time the post was made, this was taken from the journalEntryPage widget.
                            Row(children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 4.0),
                                child: Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(date)
                                      .toString(),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 4.0),
                                child: Text(
                                  DateFormat('HH:mm').format(date).toString(),
                                ),
                              )
                            ]),
                            const SizedBox(
                              height: 25,
                            ), //Used to create a gap.
                            //The text input fields start.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('The best thing that happened today was: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                                controller: bestThingData,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                cursorColor: hexStringToColor('471dbc'),
                                decoration: const InputDecoration.collapsed(
                                    hintText:
                                        'Best thing that happend to you today?')),
                            const SizedBox(height: 25),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Something I was proud of today: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                                controller: proudThingData,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                cursorColor: hexStringToColor('471dbc'),
                                decoration: const InputDecoration.collapsed(
                                    hintText:
                                        'Something you were proud of today?')),
                            const SizedBox(height: 25),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('3 Things I am grateful for: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                                controller: gratefulData,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                cursorColor: hexStringToColor('471dbc'),
                                decoration: const InputDecoration.collapsed(
                                    hintText:
                                        '3 Things you are grateful for?')),
                            const SizedBox(height: 25),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Something to improve for tommorrow: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                                controller: improveData,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                cursorColor: hexStringToColor('471dbc'),
                                decoration: const InputDecoration.collapsed(
                                    hintText:
                                        'Something to improve for tommorrow?')),
                          ],
                        ),
                      ]),
                ),
              );
            }
          }
          //When the database is being queried the CircularProgressIndicator will show the loading.
          return Center(
              child:
                  CircularProgressIndicator(color: hexStringToColor('471dbc')));
        },
      ),
      //Save & upload to firebase button.
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.check,
            semanticLabel: 'Save',
          ),
          backgroundColor: hexStringToColor('2e3887'),
          //Same checks as the AddEntry Class.
          onPressed: () async {
            if (titleData.text == '' ||
                bestThingData.text == '' ||
                proudThingData.text == '' ||
                gratefulData.text == '' ||
                improveData.text == '') {
              //Dialog is the same from the AddEntry Class
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return noText;
                  });
            }
            //If all inputs are filled out then create the data to update firebase.
            else {
              //Creating the data.
              Map<String, dynamic> data = {
                "title": titleData.text,
                "best_thing": bestThingData.text,
                "proud_of": proudThingData.text,
                "grateful": gratefulData.text,
                "improve": improveData.text,
              };
              //Need to update the data the document with the new data.
              FirebaseFirestore.instance
                  .collection('entries')
                  .doc(widget.entryId)
                  .update(data);
              //Push the user back to to the previous page, without animation.
              //This also means there is no need to refresh the page as the previous page will re-query the database automatically and find the new changes.
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ViewAnyEntry(
                            userId: _auth.getUid(),
                            entryId: widget.entryId,
                            entryTag: 'journal',
                            isHomepage: widget.isHomepage,
                            isPastJorunal: widget.isPastJorunal,
                            isProfile: widget.isProfile,
                          )));
            }
          }),
    );
  }
}

//Same dialog used in the AddEntry Class.
CupertinoAlertDialog noText = const CupertinoAlertDialog(
  title: Text("Missing Text"),
  content: Text(
    "Please fill in the all sections of the journal to save it!",
  ),
);
