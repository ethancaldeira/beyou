import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:beyou/services/auth.dart';
import 'package:beyou/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

//Code adapted from tutorial: https://www.youtube.com/watch?v=BBccK1zTgxw&t=23325s
class FirestoreConnection {
  //We need AuthService class for the querys we are about to do.
  final AuthService _auth = AuthService();

  //We need this message to upload an image to the Firestore database.
  Future<String> uploadImage(Uint8List file, String text) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String result = "Some error occurred";
    //We try first to see if we are able to upload the image.
    try {
      //We create the image URL by using StorageMethods class.
      String imageUrl = await addImageFirestore('entries', file);
      //We then need to add the entry to the firesbase collection.
      addImageEntry(imageUrl, text);
      //We then want to change the result to success.
      result = "Success";
    }
    //If there is a proble when running this code we want to catch the error.
    catch (error) {
      //We save the result as the error to string.
      result = error.toString();
    }
    //Regardless the result we want to return it.
    return result;
  }

  //Method adds the image entry to the firebase database.
  addImageEntry(imageUrl, title) async {
    //Create a map to store the image entry data.
    Map<String, dynamic> imageEntry = {
      //Saving the owner id to the current user.
      "owner_id": _auth.getUid(),
      //We need the owners username, which is accessed using retreiveUsername() method.
      "owner_username":
          await DatabaseService(uid: _auth.getUid()).retreiveUsername(),
      //Title of the image entry given in the parameter of the method.
      "title": title,
      //We want the data of the new entry.
      "date": DateTime.now(),
      //We want the formatted data of the new entry, so it can appear on the homepage.
      "formatted_date":
          DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
      //Save the tag of the entry to photo.
      "tag": 'photo',
      //Save the url of the image.
      "imageUrl": imageUrl
    };
    //Once we have the imageEntry data we can add it to the collection.
    FirebaseFirestore.instance.collection('entries').add(imageEntry);
  }

  //Method to add the image file into Firebase Storage.
  Future<String> addImageFirestore(String childName, Uint8List file) async {
    //We need to create a location inside our Firebase Storage.
    //Reference ref = FirebaseStorage.instance.ref().child(childName).child(FirebaseAuth.instance.currentUser!.uid);
    Reference ref =
        FirebaseStorage.instance.ref().child(childName).child(_auth.getUid());
    //As we know it will be an image we can create the byte list for the image file.
    String imageId = const Uuid().v1();
    //We add the image to the location in firebase storage.
    ref = ref.child(imageId);
    //To upload the image it needs to be in uint8list format.
    UploadTask uploadTask = ref.putData(file);
    //Need to wait for the new format before we can upload.
    TaskSnapshot snapshot = await uploadTask;
    //Then we need the URL for the image location in storage.
    //Call it photoUrl so we do not get confused with the other imageUrl.
    String photoUrl = await snapshot.ref.getDownloadURL();
    //We return that url back. This is what will get stored in the collection entries with the other data about the image entry.
    return photoUrl;
  }

  //For the audio entry we just need to add it to firebase database.
  addAudioEntry(file, title) async {
    //Create a map to store the audio entry data.
    Map<String, dynamic> audioEntry = {
      //Saving the owener id to the current user.
      "owner_id": _auth.getUid(),
      //We need the owners username, which is accessed using retreiveUsername() method.
      "owner_username":
          await DatabaseService(uid: _auth.getUid()).retreiveUsername(),
      //Title of the audio entry given in the parameter of the method.
      "title": title,
      //We want the data of the new entry.
      "date": DateTime.now(),
      //We want the formatted data of the new entry, so it can appear on the homepage.
      "formatted_date":
          DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
      //Save the tag of the entry to audio.
      "tag": 'audio',
      //Save the url of the audio.
      "audioUrl": file
    };
    //Once we have the audioEntry data we can add it to the collection.
    FirebaseFirestore.instance.collection('entries').add(audioEntry);
  }
}
