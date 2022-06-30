import 'package:beyou/utils/hex_color.dart';
import 'package:flutter/material.dart';

//Tutorial followed to create page: https://www.youtube.com/watch?v=GvIoBgmNgQw&t=2151s
//All the code has been adapted from the tutorial.

//This input field is for the login/sign up/forgot password screens.
TextField customTextInput(String text, IconData icon, bool isPasswordType,
    TextEditingController controller)
//Need the parameters for the input field.
{
  //Need a text field for the input.
  return TextField(
    controller: controller, //Controller is given from the parameter.
    obscureText: isPasswordType, //We only obscure the text if it is a password.
    autocorrect:
        !isPasswordType, //We can turn off the autocorrect if it is a password.
    cursorColor: hexStringToColor(
        '471dbc'), //Keep the cursor the same as the rest of the app.
    style: const TextStyle(
        color: Colors.white), //Text colour for the input of the user.
    //We can add the needed icons to the input.
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon, //Given from parameters.
        color: Colors.white70,
      ),

      //Label text acts as the hint text.
      labelText: text,
      //We want the hint text to look a little see through.
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      //We also want the input to have a background.
      filled: true,
      //Can have the label floating which we do not want.
      floatingLabelBehavior: FloatingLabelBehavior.never,
      //Sets the field background colour which we want to be see through again.
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
              width: 0, style: BorderStyle.none)), //Makes the field rounded.
    ),
    //Sets the type of the field. Needed especially for the log in page.
    //Sets the length that the user can type.
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

//This button is for the login/sign up/forgot password screens.
Container longButton(
    BuildContext context, String buttonText, Function onTapFunc)
//We need the parameters to show the button, and to execute its code.
{
  //Container to hold the button.
  return Container(
    width: MediaQuery.of(context)
        .size
        .width, //Sets button to the width of the screen.
    height: 50,
    margin:
        const EdgeInsets.only(top: 10, bottom: 20), //Prevents overflow error,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90)), //Rounds the button.
    //The actual button.
    child: ElevatedButton(
      //When it is tapped, we will run the function that the longButton is given.
      onPressed: () {
        onTapFunc(); //Paramether function we are given.
      },
      //We need the text of the button.
      child: Text(
        buttonText, //The text is given as a parameter.
        style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize:
                16), //Want black as the text colour as the button will be white.
      ),
      //We can set the button style.
      //Code from: https://www.youtube.com/watch?v=GvIoBgmNgQw&t=2151s
      style: ButtonStyle(
          backgroundColor:
              //Lets the button have a splash colour of grey when it is tapped.
              MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.grey; //Splash colour grey.
            }
            return Colors.white; //Normal white as the colour.
          }),
          //Setting the button to have rounded edges like the container the button is inside.
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}
