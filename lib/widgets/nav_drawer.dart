import 'package:beyou/screens/friends_screen.dart';
import 'package:beyou/screens/past_entries.dart';
import 'package:beyou/services/database.dart';
import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/change_time_limit.dart';
import '../screens/login_screen.dart';
import '../screens/request_screen.dart';
import '../screens/search_screen.dart';
import '../screens/sent_requests.dart';
import '../screens/settings.dart';
import '../services/auth.dart';

//Tutorial was used when creating this code, the code has been adapted from:https://www.youtube.com/watch?v=ts9n211n8ZU&t=494s

//This is the drawer that is used on the profile page.
class NavDrawer extends StatelessWidget {
  //We need _auth so we can acess the users current name, and email.
  final AuthService _auth = AuthService();

  NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //To show the drawer.
    return Drawer(
      child: Material(
        color: hexStringToColor('471dbc'), //Set the colour of the drawer.
        child: ListView(
          children: <Widget>[
            //We call the nameAndEmail method that will return the name, and email of the user.
            nameAndEmail(),
            //Then we need to show the items of the drawer.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              //Column below has all the drawer items in it.
              child: Column(
                children: [
                  //First drawerItem is the search button.
                  drawerItem(
                      text: 'Search Users', //Text for the button.
                      icon: Icons.person_search, //Person search for the icon.
                      //When the button is tapped this method is executed.
                      onTap: () =>
                          showSearch(context: context, delegate: UserSearch())),
                  const SizedBox(height: 15), //Gap to divide the items.
                  //Your friends button.
                  drawerItem(
                    text: 'Your Friends',
                    icon: Icons.people,
                    //When the button is tapped this method is executed.
                    //Users are sent to their friend list.
                    onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const FriendsListPage())),
                  ),
                  const SizedBox(height: 15), //Gap to divide the items.
                  drawerItem(
                    text: 'Requests',
                    icon: Icons.person_add,
                    //When the button is tapped this method is executed.
                    //Users sent to their friend request list.
                    onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const FriendRequestPage())),
                  ),
                  const SizedBox(height: 15), //Gap to divide the items
                  drawerItem(
                    text: 'Sent Requests',
                    icon: Icons.arrow_forward,
                    //When the button is tapped this method is executed.
                    //User sent to their sent friend requests list.
                    onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SentRequestPage())),
                  ),
                  const SizedBox(height: 15), //Gap to divide the items.
                  drawerItem(
                    text: 'Past Entries',
                    icon: Icons.update,
                    //When the button is tapped this method is executed.
                    //User sent to their past entries page.
                    onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const PastEntriesPage())),
                  ),
                  const SizedBox(height: 25), //Gap to divide the items.
                  const Divider(color: Colors.white70),
                  const SizedBox(height: 25), //Gap to item from the divider.
                  drawerItem(
                    text: 'Time Limit',
                    icon: Icons.lock_clock,
                    //When the button is tapped this method is executed.
                    //User sent to their time limit settings.
                    onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ChangeTimeLimitPage())),
                  ),
                  const SizedBox(height: 15), //Gap to divide the items.
                  drawerItem(
                    text: 'Settings',
                    icon: Icons.settings,
                    //When the button is tapped this method is executed.
                    //User sent to the settings page.
                    onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SettingsPage())),
                  ),
                  const SizedBox(height: 15), //Gap to divide the items.
                  drawerItem(
                      text: 'Log Out',
                      icon: Icons.logout,
                      //When the button is tapped this method is executed.
                      //User is logged out.
                      onTap: () async {
                        //First we set the status for the sign out.
                        await setSignOutStatus();
                        //Then we connect to firebase and sign the user out.
                        FirebaseAuth.instance.signOut().then((value) async {
                          //Once they have been signed out we sent the user back to the log in screen.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogInScreen()));
                        });
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //We need to set the status of the user when the signs out.
  setSignOutStatus() async {
    //We connect to the database.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getUid())
        .update(
      {
        "status": 'Offline',
        'log_off_time': DateTime.now(),
        'log_on_time': DateTime.now(),
        'active_time': 0
      },
      //And update the following fields.
    );
  }

  //This widget is the header of the drawer.
  Widget nameAndEmail() {
    //We need a FutureBuilder as we will run a method that will query the database.
    return FutureBuilder(
      future: DatabaseService(uid: _auth.getUid())
          .getUserData(), //Calling method getUserData
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } //If there is an error when querying the database, we need to show that to the user.
        //If the method getUserData has run successfully we can check the data.
        if (snapshot.hasData) {
          //We can save the method data to a variable called methodData.
          var methodData = snapshot.data;
          //Now we can show the data to the user.
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20).add(
                const EdgeInsets.symmetric(
                    vertical:
                        40)), //Padding aligns the text the way we want it to be.
            child: Row(
              children: [
                const SizedBox(width: 20), //Gap to the top of the drawer.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodData[
                          'name'], //Using the methodData to return the name of the user.
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors
                              .white), //White will stand out on the background of the drawer.
                    ),
                    const SizedBox(height: 4),
                    Text(
                      methodData[
                          'email'], //Using the methodData to return the email of the user.
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors
                              .white), //White will stand out on the background of the drawer.
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        //While we wait for th data we need to show the progress.
        //Normally we will do a return circular progress indicator but having a name and email as paceholders works better -
        //in this situation as the is the circular progress indicator does not look good in the drawer.
        else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20).add(
                const EdgeInsets.symmetric(
                    vertical:
                        40)), //Padding aligns the text the way we want it to be.
            child: Row(
              children: [
                const SizedBox(width: 20), //Gap to the top of the drawer.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'name',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors
                              .white), //White will stand out on the background of the drawer.
                    ),
                    SizedBox(height: 4),
                    Text(
                      'user@gmail.com',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors
                              .white), //White will stand out on the background of the drawer.
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget drawerItem({
    required String text,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    //Return a list tile.
    return ListTile(
      leading:
          Icon(icon, color: Colors.white), //Parameter icon is shown as leading.
      title: Text(text, //The parameter text.
          style: const TextStyle(
            color: Colors
                .white, //White to stand out on the background of the drawer.
            fontSize: 14,
          )),

      //When the button is tapped we need to run the parameter method of onTap.
      onTap: onTap,
    );
  }
}
