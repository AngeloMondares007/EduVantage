import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/color.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../res/fonts.dart';

class UserActivityScreen extends StatefulWidget {
  final String userUID;
  const UserActivityScreen({Key? key, required this.userUID}) : super(key: key);
  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState(userUID: userUID);
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  final ref = FirebaseDatabase.instance.ref('User');
  final auth = FirebaseAuth.instance;
  final CollectionReference userActivityCollection = FirebaseFirestore.instance.collection('ActivityLogs');
  final String userUID;
  _UserActivityScreenState({required this.userUID});
  var controller;

  // Define the delete function here
  Future<void> _deleteActivity(String documentId) async {
    try {
      await userActivityCollection.doc(documentId).delete();
      print('Activity deleted successfully.');
    } catch (error) {
      print('Error deleting activity: $error');
      // Handle error appropriately
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black87,
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        centerTitle: false,
        title: Text(
          "User Activity",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: AppFonts.alatsiRegular,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFe5f3fd),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: userActivityCollection
              .orderBy("timestamp", descending: true)
              .where("userId", isEqualTo: userUID)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No user activity found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black45)),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                return FutureBuilder<DatabaseEvent>(
                  future: FirebaseDatabase.instance
                      .ref('User')
                      .child(data['userId'])
                      .once(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    Map<String, dynamic> user = Map<String, dynamic>.from(userSnapshot.data?.snapshot.value as Map);
                    Timestamp timestamp =
                        data['timestamp'] ?? Timestamp.now();
                    return ActivityCard(
                      title: data['title'],
                      message: data['activity'],
                      timestamp: timestamp,
                      imageUrl: user['profile'] ??'',
                      userUID: user['uid'] ?? '',
                      onPressed: () async {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        User? user = auth.currentUser;
                        log(user!.providerData.toString());
                      },
                      onDeletePressed: () {
                        // Handle delete functionality here
                        // For example, you can call a function to delete the activity
                        _deleteActivity(document.id); // Assuming you have access to the document ID
                      },
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData iconData;
  final Timestamp timestamp; // New timestamp variable
  final VoidCallback onPressed;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.iconData,
    required this.timestamp, // Updated constructor
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(
            iconData,
            size: 28,
            color: Colors.blueAccent,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              SizedBox(height: 4),
              Text(
                "${_formatTimestamp(timestamp)}", // Display formatted timestamp
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
    return formattedDate;
  }
}


class ReusableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  final Color iconColor;
  const ReusableRow({Key? key,
    required this.title,
    required this.iconData,
    required this.value,
    required this.iconColor,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: Colors.black87.withOpacity(0.5))),
          leading: Icon(iconData, color: iconColor),
          trailing: Text(value,style: Theme.of(context).textTheme.displaySmall, ),
        ),
        Divider(color: AppColors.whiteColor.withOpacity(0))
      ],
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String message;
  final String imageUrl;
  final Timestamp timestamp;
  final VoidCallback onPressed;
  final String userUID;
  final VoidCallback onDeletePressed; // Add onDeletePressed callback

  const ActivityCard({
    Key? key,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.timestamp,
    required this.userUID,
    required this.onPressed,
    required this.onDeletePressed, // Updated constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            // _navigateToUserProfile(userUID);
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black87)],
              border: Border.all(color: Colors.black87),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) =>
                  Icon(CupertinoIcons.person, color: Colors.white, size: 20,),
              errorWidget: (context, url, error) =>
                  Icon(CupertinoIcons.person, color: Colors.white, size: 20,),
              imageBuilder: (context, imageProvider) => ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontSize: 12),),
            SizedBox(height: 4),
            Text(
              "${_formatTimestamp(timestamp)}",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, size: 20, color: Colors.red,),
          onPressed: onDeletePressed,
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
    return formattedDate;
  }
}

