import 'package:flutter/material.dart';
import 'package:beyou/screens/all_screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dcdg/dcdg.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //Need to lock the app orientation to portraitUp.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const BU());
  });
}

//BU class starts the application. BU is the name of the application.
class BU extends StatelessWidget {
  const BU({Key? key}) : super(key: key);

  //This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //Set the application title.
      title: 'BU',
      //Set the home of the application to LogInScreen class.
      home: LogInScreen(),
    );
  }
}
