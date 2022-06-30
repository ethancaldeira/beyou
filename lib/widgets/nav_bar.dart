import 'package:beyou/screens/tools_page.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:beyou/screens/all_screens.dart';

import '../screens/all_chats_screen.dart';
import '../utils/hex_color.dart';

//This is the floating nav bar that is shown on the main pages.
//It is created using the dot_navigation_bar api.
class NavBar extends StatefulWidget {
  //We need the index for the navbar.
  int index;
  NavBar({Key? key, required this.index}) : super(key: key);
  //Need to give the nav bar the index for the page it is currently on.
  @override
  _NavBarState createState() => _NavBarState(currentIndex: index);
}

//Collection of the pages that can be accessed.
enum PageList { home, tools, chat, profile }

class _NavBarState extends State<NavBar> {
  //Se the currentIndex as 0 for now.
  int currentIndex = 0;
  //Take the parameter of index which is given.
  _NavBarState({required this.currentIndex});

  //We set the current page to the value form the
  var selectedPage = PageList.home;

  //Need a method to change the index of the page.
  //Given an index to change the current index to.
  setIndex(index) {
    //Changes the current index to the parameter index.
    setState(() {
      currentIndex = index;
      //Changes the selectedPage to the page list value, at the current index.
      selectedPage = PageList.values[currentIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    //As the nav bar is built we need to set the current index of the nav bar.
    setIndex(currentIndex);

    return DotNavigationBar(
      //Need the margin so that there is on overflow error.
      margin: const EdgeInsets.only(left: 10, right: 10),
      //Need set the current index of the nav bar.
      currentIndex: currentIndex,
      onTap:
          movePage, //When an item is tapped we need to move the page to that item.
      items: [
        //Collection of the options
        //Home page.
        DotNavigationBarItem(
          icon: const Icon(Icons.home), //Home icon for the homepage.
          selectedColor: hexStringToColor("471dbc"), //Using the app colours.
        ),

        //Tools page.
        DotNavigationBarItem(
          icon: const Icon(Icons
              .work), //Work used to show that the tools are stored in a briefcase.
          selectedColor: hexStringToColor('2e3887'), //Using the app colours.
        ),

        //All chats page.
        DotNavigationBarItem(
          icon: const Icon(
              Icons.chat_bubble_rounded), //Chats icon for chat page..
          selectedColor: hexStringToColor("9780d8"), //Using the app colours.
        ),

        /// Profile page.
        DotNavigationBarItem(
          icon: const Icon(Icons.person), //Person icon for profile page..
          selectedColor: Colors
              .purpleAccent, //Used a type of purple to indicate to the user.
        ),
      ],
    );
  }

  //We need a method that allows us to move the page.
  void movePage(int i) {
    //Set the selected page to the value of the page list with the following index of i.
    setState(() {
      selectedPage = PageList.values[i];
    });
    //Need to check if the selected page is the home screen.
    if (selectedPage == PageList.home) {
      setIndex(0); //We set the index to the homescreen index.
      //We wait 100 milliseconds and send the user to the homescreen.
      //The delay allows the animation of the DotNavigationBar to show to the user.
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage()));
      });
    }
    //Need to check if the selected page is the tools screen.
    if (selectedPage == PageList.tools) {
      setIndex(1); //We set the index to the tools screen index.
      //We wait 100 milliseconds and send the user to the tools screen.
      //The delay allows the animation of the DotNavigationBar to show to the user.
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ToolsPage()));
      });
    }
    //Need to check if the selected page is the chat screen.
    if (selectedPage == PageList.chat) {
      setIndex(2); //We set the index to the chat screen index.
      //We wait 100 milliseconds and send the user to the chat screen.
      //The delay allows the animation of the DotNavigationBar to show to the user.
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AllChatsPage()));
      });
    }
    //Need to check if the selected page is the profile screen.
    if (selectedPage == PageList.profile) {
      setIndex(3); //We set the index to the profile screen index.
      //We wait 100 milliseconds and send the user to the profile screen.
      //The delay allows the animation of the DotNavigationBar to show to the user.
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfilePage()));
      });
    }
  }
}
