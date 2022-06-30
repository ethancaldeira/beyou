import 'package:beyou/screens/all_chats_screen.dart';
import 'package:beyou/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../utils/hex_color.dart';

//Chat page is used to show the chats between users.
//Tutorial was used when creating this code, the code has been adapted from: https://www.youtube.com/watch?v=X00Xv7blBo0
class ChatPage extends StatefulWidget {
  //Chat page takes paramaters in order to run.
  final String
      chatId; //We need the chat id to find the right document inside firebase.
  final String
      userId; //We need the userId so that we can add that to the messages when they are sent.
  final String
      friendName; //We need the friends name or the other users name to display in the Appbar.

  const ChatPage(
      {Key? key,
      required this.chatId,
      required this.userId,
      required this.friendName})
      : super(key: key);
  //Setting all the parameters to required as the code will not execute without it.
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //Need a TextEditingController for the message that the user is going to send.
  TextEditingController message = TextEditingController();

  //We need to find the messages that are sent from both the current user and their friend -
  //These need to be returned.
  Widget pastMessages() {
    //Returning a stream builder.

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.chatId)
          .collection("messages")
          .orderBy(
            'time_sent',
          )
          .snapshots(), //The stream used is a database query, querying the messages of the chat between the current user and their friend.
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //Once the query is done we need to return the collected data back to the user.
        //First we need to check that there have been past messages sent.
        if (snapshot.hasData == true) {
          //If there is data that means messages have been sent.
          //Setting a local variable messagesSent.
          var messagesSent = snapshot.data;
          return ListView.builder(
              itemCount: messagesSent.docs
                  .length, //Taking the length of the messages that have been sent in the past.
              itemBuilder: (context, index) {
                //Returning a message bubble that contains that infomation from the sent message.
                //The colour of the bubble depends on who sent the message.
                return MessageBubble(
                  message: snapshot.data!.docs[index].data()["message"],
                  sentByMe: widget.userId ==
                      snapshot.data.docs[index].data()[
                          "sent_by"], //Checks if the current user id is equal to the sent by id. This returns true or false.
                );
              });
        } //else means there are no messages that have been sent.
        else {
          //Empty Container as there is nothing to display back to the user.
          return Container();
        }
      },
    );
  }

  //Send message method adds the message data to the database.
  void sendMessage() async {
    //first checking if the message is empty or not.
    if (message.text.isNotEmpty) {
      //If the message text is not empty message data is created.
      Map<String, dynamic> messageData = {
        "sent_by": widget.userId, //Sent by is equal to the current user id.
        "message": message
            .text, //The message is equal to the message inputed from the user.
        'time_sent': DateTime.now()
            .millisecondsSinceEpoch, //Saving the time that the message is sent,
        // - using millisecondsSinceEpoch keeps the time_sent independent of time zones so users in two differnt time zones can still chat.
      };
      //Calling DatabaseService to add the new message data into the chats collection.
      DatabaseService(uid: widget.userId).addMessage(widget.chatId, messageData)
          //If there is an error with adding a new message.
          .catchError((error) {
        //We format the error so that in some cases it can be shown back to user.
        String formatError =
            error.toString().replaceAll(RegExp('\\[.*?\\]'), '');
        newMessageError(context, formatError);
      });
      //Once they have been added the message.text needs to be cleared.
      setState(() {
        message.text = "";
      });
    }
    //If the message text is empty nothing happens.
  }

//Displaying the page to the user.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Using the same style app bar as most of the app.
      appBar: AppBar(
          title: Text(
            'Chat with ${widget.friendName}', //Using the friends name in the app bar title.
            //This automatically will show ...  if the name is too long for the app bar.
            style: TextStyle(color: hexStringToColor('471dbc')),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: hexStringToColor("471dbc"),
              onPressed: () {
                //Pushes the user back to the all chats page, without any animation.
                //This is also needed as it means the page will refresh, so if the user starts a new chat
                //- they will see the new new chat when they are pushed back to the all chats page.
                //SetState() is not needed to refresh as the AllChatsPage calls to the database inside its initState()
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AllChatsPage()));
              })),
      //Stack used so that the past messages and text box can be used on the same page.
      body: Stack(
        children: [
          //The messages are shown inside the message bubbles.
          pastMessages(),
          //The Container below contains the text field for the user to type their message in.
          Container(
            alignment: Alignment
                .bottomCenter, //Has the text input sit on the bottom of the page.
            width: MediaQuery.of(context)
                .size
                .width, //Ensures the width of the of the text input takes up the whole width of the screen.
            child: Container(
              //Decoration used to give the text input a border from the past messages and a colour.
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                        width: 1.0,
                        color: hexStringToColor(
                            '471dbc')), //Setting the border to a width of 1.
                  )),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24), //Padding avoids overflow error.

              //Create a row so that a sent icon and the typed message are on the same line.
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: message,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16), //Set the style of the text typed.
                    //Set keyboardType so that if a message is long it will wrap to a next line.
                    keyboardType: TextInputType.multiline,
                    //No limit on the max lines.
                    maxLines: null,
                    cursorColor: hexStringToColor(
                        '471dbc'), //Cursor colour keeps constant with the rest of the app.
                    //hint text for the user.
                    decoration: const InputDecoration(
                        hintText: "Message ...",
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        border: InputBorder
                            .none //No border used as we have created the border by uing a container.
                        ),
                  )),
                  const SizedBox(
                    width: 15,
                  ), //Creates a gap from the input field to the send button.
                  //Icon button used to capture if the icon is tapped.
                  IconButton(
                      //When the icon is tapped call the send message method.
                      onPressed: (() {
                        sendMessage();
                      }),
                      //Icon is the send icon.
                      icon: Icon(
                        Icons.send,
                        color: hexStringToColor('471dbc'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Chat error needed incase there is an erro with creating a new chat.
newMessageError(context, error) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        //CupertinoAlertDialog keeps with the current IOS theme.
        return CupertinoAlertDialog(
          //Alerts the user to an error with creating a new chat.
          //This will show the user if there is a problem with adding a new chat message.
          title: const Text("Chat Error"),
          content: Text(
            "\nThere was an error when creating the new chat, please try agian.\n\nHint:${error.toString()}",
          ),
        );
      });
}
