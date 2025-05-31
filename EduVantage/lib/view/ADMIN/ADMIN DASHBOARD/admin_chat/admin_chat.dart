import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final ref = FirebaseDatabase.instance.ref('User');
  
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
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget getBody() {
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
              "Messages",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: Offset(0, 1))
                  ]),
              child: Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        FeatherIcons.search,
                        color: Colors.black,
                      )),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: TextField(
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search for contacts"),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),


          ],
        ),
      ),
    );
  }
}
