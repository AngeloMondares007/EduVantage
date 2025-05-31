import 'package:flutter/material.dart';

class ProgressDialog {
  static void show(BuildContext context, {String? message, IconData? icon}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              height: 200,
              width: 200,
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16,),
                  if (icon != null)
                    Icon(
                      icon,
                      size: 40,
                      color: Colors.red,
                    ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  if (message != null)
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
