import 'package:beyou/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beyou/utils/hex_color.dart';
import '../services/auth.dart';
import '../utils/hex_color.dart';
import '../widgets/entry_preview.dart';

//Class shows a list of the past entries from the user.
class PastEntriesPage extends StatefulWidget {
  const PastEntriesPage({Key? key}) : super(key: key);

  @override
  _PastEntriesPageState createState() => _PastEntriesPageState();
}

class _PastEntriesPageState extends State<PastEntriesPage> {
  //Need the id of the user to query their posts.
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        //Same AppBar style as the other pages.
        appBar: AppBar(
            title: Text('Past Entries',
                style: TextStyle(
                  color: hexStringToColor('471dbc'),
                )),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: hexStringToColor("471dbc"),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              const ProfilePage())); //Pushes the user back to the profile page, when the select the back button
                  //This forcecs a refresh of the profile page.
                }),
            elevation: 0,
            backgroundColor: Colors.white),
        backgroundColor: Colors.white,
        //We use a FutureBuilder as we query the database, for the entries.
        body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('entries')
              .where('owner_id',
                  isEqualTo: _auth
                      .getUid()) //Find the entries that match the current users id.
              .orderBy("date",
                  descending: true) //Ordered by the date that they were posted.
              .get(),
          builder: (_, snapshot) {
            //If there is an error in querying the database this must be shown to the user.
            if (snapshot.hasError) {
              return Text('Error = ${snapshot.error}');
            }
            //We need to check that the user has posted entries.
            if (snapshot.hasData) {
              //Save the data into a variable called entries, as it represents the entries from the user.
              var entries = snapshot.data?.docs;

              //It may be the case that the entries are empty.
              if (entries.toString() == '[]') {
                //In that case we want to prompt the user.
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Add Friends to see a list of them!', //Prompts the user to add friends as they have non currently.
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: hexStringToColor('471dbc'), fontSize: 32),
                  ),
                ));
              } else {
                //We need the length of the entries that this user has posted.
                var len = entries?.length;
                //To show the entries we need a list view.
                return ListView(
                    children: List.generate(
                        len!,
                        (index) =>
                            //Use our own custom widget to show the entries.
                            userEntryPreview(
                                context,
                                entries![index]['title'],
                                entries[index]['date'],
                                entries[index]['tag'],
                                entries[index].id,
                                _auth.getUid(),
                                true,
                                false)));
              }
            }
            //While we wait on the data from the database show the CircularProgressIndicator.
            return Center(
                child: CircularProgressIndicator(
              color: hexStringToColor('471dbc'),
            ));
          },
        ));
  }
}
