import 'package:flutter/material.dart';
import '../utils/hex_color.dart';

//This class is used to create the message bubbles used in the chat.
//Tutorial was used when creating this code, the code has been adapted from: https://www.youtube.com/watch?v=X00Xv7blBo0
class MessageBubble extends StatelessWidget {
  //We need to know the message text, so that it can appear in the bubble.
  final String message;
  //We need to know if the message was went by the current user. This will decide the colour of th bubble.
  final bool sentByMe;

  const MessageBubble({Key? key, required this.message, required this.sentByMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //A lot of this code was followed with: https://www.youtube.com/watch?v=X00Xv7blBo0
    //The bubbles will be different depending on who sent them.s
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sentByMe ? 0 : 14,
          right: sentByMe
              ? 14
              : 0), //We need padding for both bubbles, sent by and received by.
      alignment: sentByMe
          ? Alignment.centerRight
          : Alignment
              .centerLeft, //Aligns the sent by bubble to the right, and the received bubbles to the left.
      child: Container(
        margin: sentByMe
            ? const EdgeInsets.only(left: 25)
            : const EdgeInsets.only(
                right:
                    25), //difference of the magrin depends on who sent the message.
        padding: const EdgeInsets.only(
            top: 17,
            bottom: 17,
            left: 20,
            right:
                20), //Need the margins to avoid overflows and overlapping errors.
        decoration: BoxDecoration(
            borderRadius: sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(
                        23)) //The radius for the sent by me message is differnt as we want it to look -
                //like the message was sent from the right.
                : const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(
                        23)), //Different to the sent by as we need the received message to look like its been sent from left.
            gradient: LinearGradient(
              //Colours are important to indicate who sent the message.
              colors: sentByMe
                  //These colours show that the message was sent by the user.
                  //Colours used from: https://www.youtube.com/watch?v=X00Xv7blBo0
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  //These colours are for the received message, and are the colours used throughout the app.
                  : [hexStringToColor('5934c3'), hexStringToColor("6c4ac9")],
            )),
        //The child is the message of the bubble.
        child: Text(message,
            textAlign: TextAlign.start,
            style: const TextStyle(
                color:
                    Colors.white, //White stands out against the colours used.
                fontSize: 16, //Small font size for the message.
                fontWeight: FontWeight
                    .w300)), //Need the weight to be thin as it is a message.
      ),
    );
  }
}
