import 'package:flutter/material.dart';
import 'package:tech_media/res/color.dart';



class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
      PreferredSize(child: getAppBar(), preferredSize: Size.fromHeight(0)),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Notifications",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
            ),
        SizedBox(
          height: 130,),

            Center(
              child: Container(
                width: 200,
                height: 200,
                child: Center(
                  child: Icon(
                    Icons.notifications_rounded,
                    color: AppColors.primaryColor,
                    size: 150,


                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,),
            Center(
              child: Text(
                "Notifications will \n appear here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,),

              ),
            ),

          ],
        ),
      ),
    );
  }
}
