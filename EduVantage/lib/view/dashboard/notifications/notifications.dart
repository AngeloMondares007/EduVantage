import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Notes/NotesScreen.dart';
import 'package:tech_media/view/dashboard/tasks/tasks.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../res/fonts.dart';

class NotificationScreen extends StatefulWidget {
  final String userUID;
  const NotificationScreen({Key? key, required this.userUID}) : super(key: key);
  @override
  State<NotificationScreen> createState() => _NotificationScreenState(userUID: userUID);
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ref = FirebaseDatabase.instance.ref('User');
  final auth = FirebaseAuth.instance;
  final CollectionReference notificationCollection = FirebaseFirestore.instance.collection('Notifications');
  final String userUID;
  _NotificationScreenState({required this.userUID});

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await notificationCollection.doc(notificationId).delete();
      Fluttertoast.showToast(
        msg: "Notification deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue.shade800,
        textColor: Colors.white,
      );
    } catch (e) {
      // Handle errors if any
      print("Error deleting notification: $e");
    }
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
          "Notifications",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationCollection
            .where('userUID', isEqualTo: userUID)
            .orderBy("timeAdded", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No notifications found.'),
            );
          }

          List<DocumentSnapshot> notifications = snapshot.data!.docs;
          notifications.sort((a, b) => b['timeAdded'].compareTo(a['timeAdded']));

          // Filter out notifications based on the "message" field

          return ListView(
            children: notifications.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              Timestamp timestamp = data['timeAdded'] ?? Timestamp.now();
              String notificationId = document.id; // Get the document ID

              return NotificationCard(
                title: data['title'],
                message: data['message'],
                timestamp: timestamp,
                iconData: Icons.notifications_active,
                onDelete: () {
                  // Call the _deleteNotification function with the notification ID
                  _deleteNotification(notificationId);
                },
                onEditNotes: () {
                  // Navigate to the edit notes screen
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: NotesScreen(),
                    withNavBar: false,
                  );
                },
                onEditClass: () {
                  Utils.toastMessage('${data['title']}, ${data['message']}');
                  // // Navigate to the edit class screen
                  // PersistentNavBarNavigator.pushNewScreen(
                  //   context,
                  //   screen: HomeScreen(userUID: userUID),
                  //   withNavBar: false,
                  // );
                },
                onEditTasks: () {
                  // Navigate to the edit tasks screen
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: TaskScreen(userUID: userUID),
                    withNavBar: false,
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData iconData;
  final Timestamp timestamp;
  final VoidCallback onDelete;
  final VoidCallback onEditNotes;
  final VoidCallback onEditClass;
  final VoidCallback onEditTasks;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.iconData,
    required this.timestamp,
    required this.onDelete,
    required this.onEditNotes,
    required this.onEditClass,
    required this.onEditTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        leading: Icon(
          iconData,
          size: 24,
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
              "${_formatTimestamp(timestamp)}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () {
          // Determine which edit screen to navigate based on the notification content
          if (title == "Read your note") {
            onEditNotes();
          } else if (title == "Upcoming Class") {
            onEditClass();
          } else if (title == "Other") {
            onEditTasks();
          }
          else if (title == "Heads-Up") {
            onEditTasks();
          } else if (title == "Review") {
            onEditTasks();
          } else if (title == "Meeting") {
            onEditTasks();
          } else if (title == "Assignment") {
            onEditTasks();
          }
        },
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
            size: 18,
          ),
          onPressed: onDelete,
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

class ReusableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  final Color iconColor;
  const ReusableRow({
    Key? key,
    required this.title,
    required this.iconData,
    required this.value,
    required this.iconColor,
  }) : super(key: key);

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
