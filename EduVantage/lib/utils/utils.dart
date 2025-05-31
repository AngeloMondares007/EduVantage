import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {


  static void fieldFocus(BuildContext context, FocusNode currentNode, FocusNode nextFocus){
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static void toastMessage(String message, {Toast duration = Toast.LENGTH_LONG}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.blue.shade800,
      textColor: Colors.white,
      fontSize: 16,
      toastLength: duration,
    );
  }

}