import 'package:flutter/material.dart';

import '../screens/breathing_exercise.dart';
import '../screens/calm_walk.dart';

//This card shows the exercise option of breathing, which is found in the tools page.
Card breathingExerciseCard(context) {
  return Card(
      shadowColor: Colors.black, //Gives the appearance that the card is lifted.
      elevation: 8, //Does not need to be flush with the background.
      clipBehavior: Clip.antiAlias, //Same as the entry previews.
      //Keep the card rounded.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      //InkWell so that the users can tap on the card.
      child: InkWell(
          child: Padding(
            padding:
                const EdgeInsets.all(16.0), //Padding stops any overflow errors.
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 4.0), //Padding for the text.
                  child: Row(children: const <Widget>[
                    Text(
                      'Exercise', //Exercise is the category for the card.
                      style: TextStyle(
                          color: Colors
                              .grey), //Make the colour grey as it will look good against a white card.
                    ),
                  ]),
                ),
                //Title for the card is next.
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                  child: Row(children: const <Widget>[
                    Expanded(
                        child: Text('Breathing', //Title for the exercise.
                            style: TextStyle(
                                color: Colors
                                    .grey, //Make the colour grey as it will look good against a white card.
                                fontSize: 30, //Large text as it is the title.
                                fontWeight:
                                    FontWeight.bold))), //Bold for the title.
                    SizedBox(width: 10), //Gap from the text.
                    Icon(
                      Icons.air_sharp,
                      color: Colors.grey,
                    ) //Icon for the type of exercise it is.
                  ]),
                ),
              ],
            ),
          ),
          onTap: () {
            //When the card is tapped.
            //Push the user to the correct page for them to do the exercise.
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const BreathingExercise()));
          }));
}

Card calmWalkExerciseCard(context) {
  return Card(
      shadowColor: Colors.black, //Gives the appearance that the card is lifted.
      elevation: 8, //Does not need to be flush with the background.
      clipBehavior: Clip.antiAlias, //Same as the entry previews.
      //Keep the card rounded.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      //InkWell so that the users can tap on the card.
      child: InkWell(
          child: Padding(
            padding:
                const EdgeInsets.all(16.0), //Padding stops any overflow errors.
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 4.0), //Padding for the text.
                  child: Row(children: const <Widget>[
                    Text(
                      'Exercise', //Exercise is the category for the card.
                      style: TextStyle(
                          color: Colors
                              .grey), //Make the colour grey as it will look good against a white card.
                    ),
                  ]),
                ),
                //Title for the card is next.
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                  child: Row(children: const <Widget>[
                    Expanded(
                        child: Text('Calm Walk', //Title for the exercise.
                            style: TextStyle(
                                color: Colors
                                    .grey, //Make the colour grey as it will look good against a white card.
                                fontSize: 30, //Large text as it is the title.
                                fontWeight:
                                    FontWeight.bold))), //Bold for the title.
                    SizedBox(width: 10), //Gap from the text.
                    Icon(
                      Icons.directions_walk,
                      color: Colors.grey,
                    ) //Icon for the type of exercise it is.
                  ]),
                ),
              ],
            ),
          ),
          onTap: () {
            //When the card is tapped.
            //Push the user to the correct page for them to do the exercise.
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CalmWalk()));
          }));
}
