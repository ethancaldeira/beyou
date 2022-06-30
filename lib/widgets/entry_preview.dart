import 'package:beyou/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/view_any_entry.dart';

//Shows the preview of the entry to the user.
Widget userEntryPreview(
  BuildContext context,
  String title,
  Timestamp timestamp,
  String tag,
  String postId,
  String userId,
  bool isPastJorunal,
  bool isProfile,
)
//We need the parameters to show the user the entry data.
{
  //Change the timestamp to the DateTime data type.
  DateTime date = timestamp.toDate();
  //Need this bool to know if we are showing the homepage.
  bool isHomepage = false;
  //We need to check if we are showing the homepage by checking we are not on either the -
  //past entries page or on the profile page.
  if (isPastJorunal == false && isProfile == false) {
    isHomepage = true; //Set isHomepage to true.
  }

  //First we need to check the tag of the entry as this will decide what the the preview should look like.
  if (tag == 'journal') {
    return Card(
      shadowColor: hexStringToColor(
          "471dbc"), //Set the shadow colour to the same colour as the main app colour.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('471dbc'), //Set the colour for a journal entry.
      //Inkwell so that the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              //Need to just show the time if we are on the homepage.
              isHomepage
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Text(
                        DateFormat('HH:mm ')
                            .format(date)
                            .toString(), //Show the date in the format of time.
                        style: const TextStyle(
                            color: Colors
                                .white), //White to stand out against the background.
                      ),
                    )
                  //If we are not on the homepage we can show the date and the time.
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(children: <Widget>[
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                      ]),
                    ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Text(title, //Parameter given.
                          overflow: TextOverflow
                              .ellipsis, //Sets the ellipsis if the text is too long.
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  const SizedBox(width: 10), //Gap from the title to the icon.
                  //Show the entry icon to the user.
                  const Icon(
                    Icons.book, //Book for journal entry icon.
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        //On tap we take the user to the correct page.
        onTap: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'journal',
                        isHomepage: isHomepage,
                        isPastJorunal: isPastJorunal,
                        isProfile: isProfile,
                      ))); //Giving all the needed parameter values fo the journal entry page.
        },
      ),
    );
  }

  //Need to check if the entry is a photo.
  else if (tag == 'photo') {
    return Card(
      shadowColor: hexStringToColor(
          "471dbc"), //Set the shadow colour to the same colour as the main app colour.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('5934c3'), //Set the colour for a image entry.
      //Need to use inkwell as the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              //Need to just show the time if we are on the homepage.
              isHomepage
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Text(
                        DateFormat('HH:mm ')
                            .format(date)
                            .toString(), //Show the date in the format of time.
                        style: const TextStyle(
                            color: Colors
                                .white), //White to stand out against the background.
                      ),
                    )
                  //If we are not on the homepage we can show the date and the time.
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(children: <Widget>[
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                      ]),
                    ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Text(title, //Parameter given.
                          overflow: TextOverflow
                              .ellipsis, //Sets the ellipsis if the text is too long.
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  const SizedBox(width: 10), //Gap from the title to the icon.
                  //Show the entry icon to the user.
                  const Icon(
                    Icons.photo, //Photo for any image entry.
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        //When the card is tapped we need to send the user to the image entry.
        onTap: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'photo',
                        isHomepage: isHomepage,
                        isPastJorunal: isPastJorunal,
                        isProfile: isProfile,
                      ))); //Giving all the needed parameters for the ViewAnyEntry class.
        },
      ),
    );
  }
  //Need to check if the entry is a mood check in.
  else if (tag == 'mood') {
    return Card(
      shadowColor: hexStringToColor(
          "9EA3F5"), //Set the shadow colour to the different colour as the main app colour, this was request from user from user feedback
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('9EA3F5'), //Set the colour for a mood check in.
      //Need to use inkwell as the user can tap on the card.
      child: InkWell(
          child: Padding(
            padding:
                const EdgeInsets.all(16.0), //Padding avoids a overflow error.
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, //Helps to center any dates.
              children: <Widget>[
                //Need to just show the time if we are on the homepage.
                isHomepage
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                      )
                    //If we are not on the homepage we can show the date and the time.
                    : Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Row(children: <Widget>[
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(date)
                                .toString(), //Show the formatted date.
                            style: const TextStyle(
                                color: Colors
                                    .white), //White to stand out against the background.
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('HH:mm ')
                                .format(date)
                                .toString(), //Show the date in the format of time.
                            style: const TextStyle(
                                color: Colors
                                    .white), //White to stand out against the background.
                          ),
                        ]),
                      ),
                //Now for the title.
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0, bottom: 0.0), //Avoids an overflow error.
                  child: Row(children: const <Widget>[
                    Expanded(
                        child: Text(
                            'Mood Check In', //Title is always mood check in
                            overflow: TextOverflow
                                .ellipsis, //Will stop an overflow if the device is small.
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.bold))), //Bold for the title.
                    SizedBox(width: 10), //Gap from the title to the icon.
                    //Icon for the mood check in.
                    Icon(
                      Icons
                          .emoji_emotions, //Using a smiley face as the icon for the mood check in.
                      color: Colors.white,
                    )
                  ]),
                ),
              ],
            ),
          ),
          //We need to send the user to the mood check in view.
          onTap: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ViewAnyEntry(
                          userId: userId,
                          entryId: postId,
                          entryTag: 'mood',
                          isHomepage: isHomepage,
                          isPastJorunal: isPastJorunal,
                          isProfile: isProfile,
                        ))); //To do so need to give all the ViewAnyEntry class all the needed values.
          }),
    );
  }
  //Need to check if the entry is a audio entry
  else if (tag == 'audio') {
    return Card(
      shadowColor: hexStringToColor(
          "967bb6"), //Set the shadow colour to the same colour as the main app colour.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('967bb6'), //Set the colour for a audio entry.
      //Inkwell so that the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              //Need to just show the time if we are on the homepage.
              isHomepage
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Text(
                        DateFormat('HH:mm ')
                            .format(date)
                            .toString(), //Show the date in the format of time.
                        style: const TextStyle(
                            color: Colors
                                .white), //White to stand out against the background.
                      ),
                    )
                  //If we are not on the homepage we can show the date and the time.
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(children: <Widget>[
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White to stand out against the background.
                        ),
                      ]),
                    ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Text(title, //Parameter given.
                          overflow: TextOverflow
                              .ellipsis, //Sets the ellipsis if the title is too long.
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  const SizedBox(width: 10), //Gap from the title to the icon.
                  //Show the entry icon to the user.
                  const Icon(
                    Icons.mic, //Mic shows that it is an audio entry.
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        onTap: () {
          //Send the user to the ViewAnyEntry class and set it to audio.
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'audio',
                        isHomepage: isHomepage,
                        isPastJorunal: isPastJorunal,
                        isProfile: isProfile,
                      )));
        },
      ),
    );
  }

  //If the entry is none of the following there has been an error.
  else {
    return const Text(
        "Erorr Reading for Firebase, tag not read correctly, should be Journal, Audio, Photo");
  }
}

//Now we need to create entry preview for friends.
Widget friendEntryPreview(
    String postId,
    BuildContext context,
    String userId,
    String title,
    Timestamp timestamp,
    int index,
    String tag,
    String name,
    bool isHomepage)

//We need the parameters to show the user the entry data.
//isHomepage tells us if the preview is on the homepage.
{
  //The code is similar although we need to show the friends username.
  //Change the timestamp to the DateTime data type.
  DateTime date = timestamp.toDate();

  //First we need to check the tag of the entry as this will decide what the the preview should look like.
  if (tag == 'journal') {
    return Card(
      shadowColor: hexStringToColor(
          "77DF79"), //Set the shadow colour to the same colour as the preview.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('77DF79'), //Set the colour for a journal entry.
      //Inkwell so that the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom:
                        4.0), //Stops the text being to close to the top of the card.
                child: Row(children: <Widget>[
                  Text(
                    name, //The username of the friend is shown, by using the parameter name.
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(), //Puts the username and the date/or time on opposite ends of the card.
                  //If we are on the homepage we do not need to show the date, but rather the time of the post.
                  isHomepage
                      ? Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        )
                      : Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        ),
                ]),
              ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Text(title, //Parameter given.
                          overflow: TextOverflow
                              .ellipsis, //Sets the ellipsis if the text is too long.
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  const SizedBox(width: 10), //Gap from the title to the icon.
                  //Show the entry icon to the user.
                  const Icon(
                    Icons.book, //Book for journal entry icon.
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        //On tap we send the user to the mood check in of their friend.
        onTap: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'journal',
                        isHomepage: isHomepage,
                        isPastJorunal: false,
                        isProfile: false,
                      ))); //To do so need to give all the ViewAnyEntry class all the needed values.
        },
      ),
    );
  }
  //Need to check if the entry is a photo.
  else if (tag == 'photo') {
    return Card(
      shadowColor: hexStringToColor(
          "44D362"), //Set the shadow colour to the same colour as the preview.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('44D362'), //Set the colour for a image entry.
      //Inkwell so that the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom:
                        4.0), //Stops the text being to close to the top of the card.
                child: Row(children: <Widget>[
                  Text(
                    name, //The username of the friend is shown, by using the parameter name.
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(), //Puts the username and the date/or time on opposite ends of the card.
                  //If we are on the homepage we do not need to show the date, but rather the time of the post.
                  isHomepage
                      ? Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        )
                      : Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        ),
                ]),
              ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Text(title, //Parameter given.
                          overflow: TextOverflow
                              .ellipsis, //Sets the ellipsis if the text is too long.
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  const SizedBox(width: 10), //Gap from the title to the icon.
                  //Show the entry icon to the user.
                  const Icon(
                    Icons.photo, //Photo as the entry is an image.
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        //On tap we send the user to the image entry page of their friend.
        onTap: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'photo',
                        isHomepage: isHomepage,
                        isPastJorunal: false,
                        isProfile: false,
                      ))); //To do so need to give all the ViewAnyEntry class all the needed values.
        },
      ),
    );
  }
  //Need to check if the entry is a mood check in.
  else if (tag == 'mood') {
    return Card(
      shadowColor: hexStringToColor(
          "6BAF92"), //Set the shadow colour to the same colour as the preview.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('6BAF92'), //Set the colour for a mood check in.
      //Inkwell so that the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom:
                        4.0), //Stops the text being to close to the top of the card.
                child: Row(children: <Widget>[
                  Text(
                    name, //The username of the friend is shown, by using the parameter name.
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(), //Puts the username and the date/or time on opposite ends of the card.
                  //If we are on the homepage we do not need to show the date, but rather the time of the post.
                  isHomepage
                      ? Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        )
                      : Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        ),
                ]),
              ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 0.0), //Avoids an overflow error.
                child: Row(children: const <Widget>[
                  Expanded(
                      child: Text(
                          'Mood Check In', //Title is always mood check in
                          overflow: TextOverflow
                              .ellipsis, //Will stop an overflow if the device is small.
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  SizedBox(width: 10), //Gap from the title to the icon.
                  //Icon for the mood check in.
                  Icon(
                    Icons
                        .emoji_emotions, //Using a smiley face as the icon for the mood check in.
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        //On tap we send the user to the mood check in of their friend.
        onTap: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'mood',
                        isHomepage: isHomepage,
                        isPastJorunal: false,
                        isProfile: false,
                      )));
        },
      ),
    );
  }
  //Need to check if the tag is for an audio entry.
  else if (tag == 'audio') {
    return Card(
      shadowColor: hexStringToColor(
          "006a4e"), //Set the shadow colour to the same colour as the preview.
      elevation: 8, //Elevation to keep the card off the background
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Rounds the cards edges
      ),
      color: hexStringToColor('006a4e'), //Set the colour for a audio entry.
      //Inkwell so that the user can tap on the card.
      child: InkWell(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), //Padding avoids a overflow error.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, //Helps to center any dates.
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom:
                        4.0), //Stops the text being to close to the top of the card.
                child: Row(children: <Widget>[
                  Text(
                    name, //The username of the friend is shown, by using the parameter name.
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(), //Puts the username and the date/or time on opposite ends of the card.
                  //If we are on the homepage we do not need to show the date, but rather the time of the post.
                  isHomepage
                      ? Text(
                          DateFormat('HH:mm ')
                              .format(date)
                              .toString(), //Show the date in the format of time.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        )
                      : Text(
                          DateFormat('dd/MM/yyyy')
                              .format(date)
                              .toString(), //Show the formatted date.
                          style: const TextStyle(
                              color: Colors
                                  .white), //White will stand out on the background.
                        ),
                ]),
              ),
              //Now for the title.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 0.0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Text(title, //Parameter given.
                          overflow: TextOverflow
                              .ellipsis, //Sets the ellipsis if the text is too long.
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold))), //Bold for the title.
                  const SizedBox(width: 10), //Gap from the title to the icon.
                  //Show the entry icon to the user.
                  const Icon(
                    Icons.mic,
                    color: Colors.white,
                  )
                ]),
              ),
            ],
          ),
        ),
        onTap: () {
          //Send the user to the ViewAnyEntry class and set it to audio.
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ViewAnyEntry(
                        userId: userId,
                        entryId: postId,
                        entryTag: 'audio',
                        isHomepage: isHomepage,
                        isPastJorunal: false,
                        isProfile: false,
                      )));
        },
      ),
    );
  }
  //If the entry is none of the following there has been an error.
  else {
    return const Text(
        "Erorr Reading for Firebase, tag not read correctly, should be Journal, Audio, Photo");
  }
}
