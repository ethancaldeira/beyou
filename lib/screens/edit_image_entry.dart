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

//Class for users to edit a image entry.
class EditImageEntry extends StatefulWidget {
  //Need the entryId in order to query the database.
  final String entryId;
  //Following bool values send the user back to the correct page from the ViewAnyEntry Class.
  final bool isHomepage; //Send users back to the homepage.
  final bool isPastJorunal; //Past journal page.
  final bool isProfile; //Or Profile page.

  const EditImageEntry(
      {Key? key,
      required this.entryId,
      required this.isHomepage,
      required this.isPastJorunal,
      required this.isProfile})
      : super(key: key);
  @override
  _EditImageEntryState createState() => _EditImageEntryState();
}

class _EditImageEntryState extends State<EditImageEntry> {
  //To get the current users id we need AuthService().
  final AuthService _auth = AuthService();
  //We need variables to add the data from the firebase to.
  late TextEditingController titleData;
  late String imageUrl;
  late DateTime date;

  //Method deletes the post using the entryId parameter
  void deleteEntry() async {
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
      //We get the reference to delete the image.
      Reference storageReference =
          FirebaseStorage.instance.refFromURL(value['imageUrl']);
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
            'Edit Image Entry',
            style: TextStyle(color: hexStringToColor("471dbc")),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor("471dbc"),
            onPressed: () {
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
                      'Error loading Image')); //Returns an error message to the user.
            }
            //If there is data inside the varaible docs we can extract that data.
            else {
              //Setting all the values for the attributes we were initialised as late.
              date = docs![0]['date']
                  .toDate(); //Need to have the toDate() method as the date is stored as a timestamp in firebase.
              titleData = TextEditingController(
                  text: docs[0]['title']
                      .toString()); //Making the title from firebase the exisiting text for the TextEditingController.
              imageUrl = docs[0]['imageUrl']; //Adding the url for the image.

              //Returning the same screen that is shown in the imageEntryPage widget.
              return SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity, //Image the width of the page.
                        child:
                            //Code was adapted from the source: https://stackoverflow.com/questions/53577962/better-way-to-load-images-from-network-flutter
                            Image.network(imageUrl.toString(),
                                fit: BoxFit.cover, loadingBuilder:
                                    (BuildContext context, Widget child,
                                        ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                              child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ));
                          //Returns the CircularProgressIndicator as it loads the image.
                          //The indicator moves with the progress of the loading of the image.
                        }),
                      ),
                      Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          //Similar TextFormField as from EditEntry Class.
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
                                  hintText: 'Title')),
                          //Takes the users input for a new title.

                          const SizedBox(
                            height: 20,
                          ), //Gap to the dates.
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 15.0),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(date)
                                        .toString(),
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 15.0),
                                  child: Text(
                                    DateFormat('HH:mm').format(date).toString(),
                                  ),
                                )
                              ])) //Date from the database used.
                        ],
                      ),
                    ]),
              );
            }
          }
          //While we query the database the CircularProgressIndicator is shown.
          return const Center(child: CircularProgressIndicator());
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
            if (titleData.text == '') {
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
                            entryTag: 'photo',
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
