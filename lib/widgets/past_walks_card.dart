import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//This widget is the card that is used to display the past walks that the user has done.
Widget pastWalkCard(
  BuildContext context,
  String miles,
  Timestamp timestamp,
  String duration,
  String calories,
  String steps,
)
//We need these parameters to show the data back to the user.
{
  //Changing the timestamp parameter to a DateTime data type as we need to show it to the user.
  DateTime date = timestamp.toDate();
  //The card style is a bit different to the other cards within the app.
  return Card(
    shadowColor: Colors.black, //Shadow gives the card more lift.
    elevation: 8, //Shows that it is above the background.
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
          12), //Need to keep the card rounded at the edges.
    ),

    child: Padding(
      padding:
          const EdgeInsets.all(16.0), //Padding to stop any overflow errors.
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Row(children: <Widget>[
              Text(
                DateFormat('dd/MM/yyyy')
                    .format(date)
                    .toString(), //Important to show the date of the the walk.
                style: const TextStyle(
                    color: Colors
                        .black), //Black to stand out on the white background of the card.
              ),
              const Spacer(), //Spacer keeps both the date and time on opposite needs of the card.
              Text(
                "${DateFormat('HH:mm ').format(date).toString()} ", //Important to show the time of the the walk.
                style: const TextStyle(color: Colors.black),
              ),
            ]),
          ),
          const SizedBox(
            height: 20,
          ), //Gap from the date and time to the data.
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0), //Padding to stop any overlapping of text.
            child: Row(children: <Widget>[
              Expanded(
                  child: Text(
                      "$steps Steps", //Shows the steps that the user has taken.
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight
                              .bold))), //Need the font to be bold as it stands out more.
            ]),
          ),
          const SizedBox(
            height: 20,
          ), //Gap to the other data that will be shown.
          Row(
            children: [
              const SizedBox(
                width: 20,
              ), //Keeps the data away from the edge of the card.
              //Column for the distance data that needs to be shown.
              Column(
                children: [
                  const Icon(Icons.directions_run),
                  Text(miles),
                  const Text('Distance'),
                ],
              ),
              //Spacer keeps the data evenly spread out on the card.
              const Spacer(),
              //Column for the calories data that needs to be shown.
              Column(
                children: [
                  const Icon(Icons.local_fire_department),
                  Text(calories),
                  const Text('Calories'),
                ],
              ),
              //Spacer keeps the data evenly spread out on the card.
              const Spacer(),
              //Column for the duration data that needs to be shown.
              Column(
                children: [
                  const Icon(Icons.watch_later_rounded),
                  Text(duration),
                  const Text('Duration'),
                ],
              ),
              const SizedBox(
                width: 20,
              ), //Keeps the data away from the edge of the card.
            ],
          ),
        ],
      ),
    ),
  );
}
