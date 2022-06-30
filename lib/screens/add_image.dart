import 'dart:typed_data';
import 'package:beyou/utils/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_storage.dart';
import 'all_screens.dart';

//Adding a new image screen.
class AddImageScreen extends StatefulWidget {
  //Takes the file that the user selects from the homepage
  final Uint8List? file;
  const AddImageScreen({Key? key, required this.file}) : super(key: key);
  @override
  _AddImageScreenState createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  //Setting boolean value to check if we are loading the image.
  bool isLoading = false;
  //Creating a TextEditingController to take the title input from the user.
  TextEditingController titleData = TextEditingController();

  //Code adapted from tutorial: https://www.youtube.com/watch?v=BBccK1zTgxw&t=23325s
  tryUploadImage(text) async {
    Uint8List? _file = widget.file;
    //Sets the boolean to true to begin the loading process.
    setState(() {
      isLoading = true;
    });
    //Try to see if the selected image can be uploaded to Firestore.
    try {
      //Add the value of the firestore method into a variable.
      //Giving the method two variables of file and text.
      String response = await FirestoreConnection().uploadImage(
        //_file with a null check, ensuring the value is not null.
        _file!,
        //Text is title text of the image.
        text,
      );
      //Check the value of the method, testing whether it is a success or failure.
      if (response == "Success") {
        setState(() {
          //Setting a delay before navigating the user back to the homepage.
          //Delay is so the image can be uploaded to the database.
          Future.delayed(const Duration(milliseconds: 50), () {
            //No longer loading the value.
            isLoading = false;
            //Navigate method, sends the user back to the homepage.
            navigateHomePage();
          });
        });
      } else {} //Response should only be a success.
    } catch (error) //Catch any error.
    {
      setState(() {
        //Print the error to terminal.
        print('Fail: $error');
        //Stop the loading process but do not naviagate user to homepage.
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Creates the image file from the parameter that the class is given
    Uint8List? _file = widget.file;

    //Checks if the loading process is happening, this should take place once the user has done entering the title.
    return !isLoading
        ? Scaffold(
            //Create Appbar and keeping the constant theme.
            appBar: AppBar(
                title: Text('Upload Image',
                    style: TextStyle(color: hexStringToColor('471dbc'))),
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: hexStringToColor('471dbc'),
                  onPressed: () {
                    //Calls navigateHomePage method to pushes the user back to the homepage and -
                    //refreshes the homepage so they can see their uploaded image.
                    navigateHomePage();
                  },
                )),

            body: Column(
              children: <Widget>[
                Center(
                  child:
                      //Sized box holds the selected image.
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.35, //Shows the height of the image at only 0.35 times the screens width.
                          width: double
                              .infinity, //Has the image the size of the screen.
                          child: AspectRatio(
                              aspectRatio:
                                  487 / 451, //Gives the image an aspect ratio.
                              child:
                                  //Container stores the image.
                                  Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                fit: BoxFit
                                    .fill, //set the image to fill the box that it is inside
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(
                                    _file!), //Has the image displayed by using the MemoryImage method.
                                //Also uses ! as a null check to check that the _file is not a null value.
                              ))))),
                ),
                //Below is the form the text input from the user.
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0), //Padding to prevent an overflow error.
                  child: TextFormField(
                      controller:
                          titleData, //Sets the controller to the TextEditingController initialised earlier.
                      keyboardType:
                          TextInputType.multiline, //Sets the keyboard type.
                      maxLines: 1, //Max lines to only one.
                      textAlign: TextAlign
                          .center, //Have the text appear in the center of the.
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            45), //Limits the title to only 45 characters.
                      ],
                      style: const TextStyle(
                          fontSize: 25), //Setting the size of the title.
                      cursorColor: hexStringToColor(
                          '471dbc'), //Set cursor to the main colour of the app for consistency.
                      decoration: const InputDecoration.collapsed(
                          hintText:
                              'Give this image a title')), //Have a hint text for the user.
                ),
              ],
            ),
            //floatingActionButton to save the title and the image that the user has selected.
            floatingActionButton: FloatingActionButton(
                backgroundColor: hexStringToColor(
                    '2e3887'), //Same colour as the add entry button on the homepage to keep design consistency.
                //Icon used to indicate that the button is a save button.
                child: const Icon(
                  Icons.check,
                  semanticLabel: 'Save',
                ),
                onPressed: () async {
                  //Checks that there is a title input from the user.
                  if (titleData.text == '') {
                    //Dialog shown to user to inform them to add a title.
                    //Prevents an image being uploaded to firebase without a title.
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          //CupertinoAlertDialog used as all the dialogs within the app are CupertinoAlertDialog.
                          return const CupertinoAlertDialog(
                            title: Text("Missing Title"),
                            content: Text(
                              "Please give this image a title to save it!",
                            ),
                          );
                        });
                  } else {
                    //Await the outcome of the tryUploadImage, which takes the parameter of titleData.text as that is the users inputted value for the title.
                    await tryUploadImage(titleData.text);
                  }
                }),
          )
        //When isLoading is equal to true the page will reutrn a CircularProgressIndicator to show that an image is being uploaded.
        : Scaffold(
            body: Center(
                child: CircularProgressIndicator(
            color: hexStringToColor('471dbc'),
          )));
  }

//Method to navigate user to the homepage
  navigateHomePage() {
    //Refreshes the homepage to show any changes to the entries that the user has done.
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage())).then((value) => setState(() {}));
  }
}
