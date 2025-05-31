import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../res/components/Task.dart';

class ProfileScreen2 extends StatefulWidget {
  final String userId;

  const ProfileScreen2({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreen2State createState() => _ProfileScreen2State();
}

class _ProfileScreen2State extends State<ProfileScreen2> {
  int completedTasksCount = 0; // Initialize completedTasksCount

  @override
  void initState() {
    super.initState();
    checkTasksCompletion(); // Call method to check tasks completion on widget initialization
  }

  Future<void> checkTasksCompletion() async {
    try {
      // Simulate fetching data
      await Future.delayed(Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userUID', isEqualTo: widget.userId)
          .get();

      completedTasksCount = querySnapshot.docs
          .where((doc) =>
      doc.data() != null &&
          (doc.data() as Map<String, dynamic>).containsKey('isDone') &&
          (doc.data() as Map<String, dynamic>)['isDone'] == true)
          .length;

      setState(() {
        if (completedTasksCount >= 20) {
          CircleAvatar(
            backgroundColor: Colors.yellow, // Customize badge color
            child: Icon(Icons.star, color: Colors.white),
          );
        } });
    } catch (error) {
      print('Error fetching tasks data: $error');
      // Handle error accordingly
    }
  }


  @override
  Widget build(BuildContext context) {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('User').child(widget.userId);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Row(
          children: [
            Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            if (completedTasksCount >= 20) // Check if badge should be shown
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => TaskMasterDialog(), // Show the custom dialog
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.indigo, // Customize badge color
                  child: Icon(CupertinoIcons.calendar_today, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            content: CachedNetworkImage(
                              imageUrl: map['profile'] ?? '',
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.no_photography_rounded, color: Colors.red, size: 30,),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: CachedNetworkImageProvider(map['profile'] ?? ''),
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    map['userName'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.person_alt,
                          color: CupertinoColors.activeBlue,
                        ),
                        SizedBox(width: 10),
                        Text('Username:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(
                      map['userName'] ?? '',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          color: CupertinoColors.destructiveRed,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Department:',
                          style: TextStyle(
                              fontFamily: AppFonts.alatsiRegular,
                              fontSize: 14,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                    title: Text(
                      map['department'] ?? '',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.book_rounded,
                          color: CupertinoColors.activeGreen,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Course:',
                          style: TextStyle(
                              fontFamily: AppFonts.alatsiRegular,
                              fontSize: 14,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                    title: Text(
                      map['course'] ?? '',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          color: CupertinoColors.systemIndigo,
                        ),
                        SizedBox(width: 10),
                        Text('Student Number:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),

                    title: Text(
                      map['studentNumber'] ?? '',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.phone_fill,
                          color: CupertinoColors.activeOrange,
                        ),
                        SizedBox(width: 10),
                        Text('Phone:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(
                      map['phone'] ?? '',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      // Handle Email tap
                      // For example, show a dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            elevation: 0,
                            backgroundColor: Colors.white,
                            title: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: GestureDetector(
                              onTap: () {
                                String email = map['email'];
                                if (email.isNotEmpty) {
                                  String mailtoUrl = 'mailto:$email';
                                  launchUrlString(mailtoUrl);
                                }
                              },
                              child: Text(
                                map['email'] ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: AppFonts.alatsiRegular,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.mail_solid,
                            color: CupertinoColors.systemPurple),
                        SizedBox(width: 10),
                        Text('Email:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(map['email'] ?? '',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.interests_rounded,
                          color: CupertinoColors.systemMint,
                        ),
                        SizedBox(width: 10),
                        Text('Interests:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(
                      map['interests'] != null && (map['interests'] as List).isNotEmpty
                          ? map['interests'] != null ? map['interests'].join(', ') : ''
                          : 'No interests',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),


                ],
              ),
            );
          } else {
            return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
