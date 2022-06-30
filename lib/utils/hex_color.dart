import 'package:flutter/material.dart';

//The colour of the app was found using hex, so we need a hex function to turn the hex value into a colur.
//This code was found: https://www.youtube.com/watch?v=GvIoBgmNgQw
hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}
