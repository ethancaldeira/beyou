import 'dart:async';

import 'package:beyou/screens/past_walks.dart';
import 'package:beyou/screens/tools_page.dart';
import 'package:flutter/material.dart';
import '../utils/hex_color.dart';
import '../widgets/calm_walk_display.dart';

//Class for the exercise Calm Walk.
class CalmWalk extends StatefulWidget {
  const CalmWalk({Key? key}) : super(key: key);

  @override
  _CalmWalkState createState() => _CalmWalkState();
}

class _CalmWalkState extends State<CalmWalk> {
  //Creates a list of attributes that are needed for collecting infomation from the devices sensors.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Same app bar as the other pages.
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Calm Walk',
            style: TextStyle(color: hexStringToColor('471dbc'))),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: hexStringToColor('471dbc'),
            onPressed: () {
              //Send users back to the tool page.
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ToolsPage()));
            }),
        //Need to show the past walks as an option.
        actions: [
          IconButton(
              icon: const Icon(Icons.update),
              color: hexStringToColor('471dbc'),
              onPressed: () {
                //Sends the users to the past walk page.
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const PastWalks()));
              })
        ],
      ),
      //Need a sized box to hold the calm walk widget.
      body: SizedBox(
        height: MediaQuery.of(context)
            .size
            .height, //Set the widget height of the page to that of the page.
        width: MediaQuery.of(context)
            .size
            .width, //Set the widget width of the page to that of the page.
        //Need the widget to be scrollable.
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Show the calm walk display.
              CalmWalkDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}
