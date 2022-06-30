import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../widgets/past_walks_card.dart';
import 'calm_walk.dart';

//This class is used to display the past walks the user has done.
class PastWalks extends StatefulWidget {
  const PastWalks({Key? key}) : super(key: key);
  @override
  _PastWalksState createState() => _PastWalksState();
}

class _PastWalksState extends State<PastWalks> {
  //We need auth as we are going to query the database.
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Same style app bar as the rest of the application.
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Past Walks',
            style: TextStyle(color: hexStringToColor('471dbc')),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: hexStringToColor('471dbc'),
            ),
            onPressed: () {
              //Send users back to the calm walk page.
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CalmWalk()));
            },
          ),
        ),
        //For the body of the application we need to use a future builder as we are querying the database.
        body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('exercises') //Need to check the exercise collection.
              .where('owner_id',
                  isEqualTo: _auth
                      .getUid()) //Querying the database to match the owner_id with the current users id.
              .get(),
          builder: (_, snapshot) {
            //Checking if there was an error with the query
            if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); //If there is an error it should be returned to the user.
            }
            //If there is data inside the query.
            if (snapshot.hasData) {
              //we set the data to a variable called docs.
              var docs = snapshot.data?.docs;
              //We check if docs is empty.
              if (docs.toString() == '[]') {
                //If it is empty it means the user has not saved a walk so we need to inform them of that.
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(
                            15.0), //Padding prevents an overflow error.
                        child: Text(
                            'Save walk to see a list of past walks!', //Prompts the user to save walk as they have none saved currently.
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: hexStringToColor('471dbc'),
                                fontSize: 32))));
              } else {
                //We need the length of the data, so the the number of past walks.
                var len = docs?.length;
                //We return the number of past walks, inside a list view.
                //We do not need to remove the auto padding from the list view as this list has a dedicated page.
                return ListView(
                    children: List.generate(
                        len!, //Using the length of the past walks.
                        (index) => pastWalkCard(
                            context,
                            docs![index]['distance'],
                            docs[index]['date'],
                            docs[index]['duration'],
                            docs[index]['calories'],
                            docs[index][
                                'steps']))); //Use the pre-built pastWalkCard to display the past walks.
                //Passing the card the needed infomation from the database to display properly.
              }
            }
            return Center(
                child: CircularProgressIndicator(
              color: hexStringToColor('471dbc'),
            )); //Shows the CircularProgressIndicator in the colour style of the application.
          },
        ));
  }
}
