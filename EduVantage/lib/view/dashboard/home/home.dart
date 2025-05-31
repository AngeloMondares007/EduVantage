import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/class/create_class.dart';
import 'package:tech_media/view/dashboard/class/edit_class.dart';
import 'package:tech_media/view/dashboard/profile/profile.dart';
import 'package:tech_media/view/dashboard/notifications/notifications.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../res/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import '../dashboard_screen.dart' as dashboard;
import '../../../utils/utils.dart';
late Timer appTimer;

class HomeScreen extends StatefulWidget {
  final String userUID;

  HomeScreen({required this.userUID, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState(userUID: userUID);
}

class _HomeScreenState extends State<HomeScreen> {
  final String userUID;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool hasNewNotification = true; // Example condition to check for new notifications
  _HomeScreenState({required this.userUID});

  final CollectionReference notesCollection =
  FirebaseFirestore.instance.collection('Notes');
  final CollectionReference classCollection =
  FirebaseFirestore.instance.collection('Class');
  final CollectionReference taskCollection =
  FirebaseFirestore.instance.collection('Tasks');
  final CollectionReference notificationCollection =
  FirebaseFirestore.instance.collection('Notifications');
  // final CollectionReference messagesCollection =
  // FirebaseFirestore.instance.collection('messages');
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('User');
  late Timer _timer;
  var controller;
  String? userProfile;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    controller = dashboard.tabController;
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/icon');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (value) {
          onSelectNotification(value.payload);
        },
        onDidReceiveNotificationResponse: (value) {
          onSelectNotification(value.payload);
        }
    );
    _startScheduling();
    requestNotificationPermission();
    _fetchUser();
  }

  void _startScheduling() {
    _scheduleNotifications();
    _scheduleNextNotification();
  }

  void _scheduleNextNotification() {
    Future.delayed(Duration(seconds: 1), () {
      _scheduleNotifications();
      _scheduleNextNotification();
    });
  }

  void requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      // Permission granted
    } else if (status.isDenied) {
      // Permission denied
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  void markAsDone(String taskID) {
    toggleDoneStatusInFirestore(taskID, true);
    Utils.toastMessage('You marked this task as done');
  }

  Future<String> getUserName(String userUID) async {
    try {
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .ref('User')
          .child(userUID)
          .once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map;
        String userName = userData['userName']; // Assuming 'userName' is the key for the user's name
        return userName;
      } else {
        return ''; // Return an empty string if user data is not found
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  Future<void> toggleDoneStatusInFirestore(String taskId, bool isDone) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).update({
        'isDone': isDone,
        'completionDate': DateTime.now()
      });

      // Retrieve user name for logging
      String userName = await getUserName(widget.userUID);

      // Add log entry to Firestore
      await FirebaseFirestore.instance.collection('ActivityLogs').add({
        "title": "Task Marked as Done",
        "activity": '$userName marked a task as done',
        "timestamp": Timestamp.now(),
        "userId": widget.userUID,
      });

      print("Task status updated in Firestore and logged");
    } catch (e) {
      print("Error updating task status in Firestore: $e");
    }
  }


  Future<void> _fetchUser() async {
    final ref = FirebaseDatabase.instance.ref('User');
    ref.child(userUID).onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      setState(() {
        userProfile = value['profile'].toString();
      });
    });
  }

  Future<void> _scheduleNotifications() async {
    // Get the current time
    var now = DateTime.now();
    // Query schedules that are within the next 10 minutes
    var schedules = await classCollection
        .where('userUID', isEqualTo: userUID)
        .get();
    var tasks = await taskCollection
        .where('userUID', isEqualTo: userUID)
        .get();
    var notes = await notesCollection
        .where('userUID', isEqualTo: userUID)
        .get();
    // var messages = await messagesCollection
    //     .where('timestamp', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(Duration(seconds: 30))))
    //     .where('receiverId', isEqualTo: userUID)
    //     .get();
    // Iterate over the schedules
    schedules.docs.forEach((schedule) {
      // Extract schedule data
      var data = schedule.data() as Map<String, dynamic>;
      if (DateFormat('h:mm:ss a').format(data["startTime"].toDate()) == DateFormat('h:mm:ss a').format(now.add(Duration(minutes: 10)))) {
        var subject = data['subjectName'];
        var startTime = (data['startTime']! as Timestamp).toDate(); // Convert Timestamp to DateTime
        // Schedule a notification for each schedule
        _scheduleNotification("Upcoming Class", 'You have a class on $subject starting soon!');
        _addNotificationToFirestore("Upcoming Class", 'You have a class on $subject starting soon!');
      }
    });
    tasks.docs.forEach((schedule) {
      // Extract schedule data
      var data = schedule.data() as Map<String, dynamic>;
      if (DateFormat('MMM d, y').format(data["date"].toDate()) + " " + data["startTime"]+" 00" == DateFormat('MMM d, y h:mm a ss').format(now.add(Duration(minutes: 10)))) {
        var taskType = data['taskType'];
        var subject = data['subjectName'];
        var description = data['description'];
        var message = '$subject: $description';
        // Schedule a notification for each schedule
        _scheduleNotification(taskType, message);
        _addNotificationToFirestore(taskType, message);
      }
    });
    notes.docs.forEach((note) {
      // Extract schedule data
      var data = note.data() as Map<String, dynamic>;
      if (data['notificationDateTime'] != null && DateFormat('MMM d, y h:mm a ss').format(data["notificationDateTime"].toDate()) == DateFormat('MMM d, y h:mm a ss').format(now.add(Duration(minutes: 3)))) {
        var noteTitle = data['title'];
        // Schedule a notification for each notes
        _scheduleNotification("Read your note", "Don't forget to read $noteTitle!");
        _addNotificationToFirestore("Read your note", "Don't forget to read $noteTitle!");
      }
    });
    // messages.docs.forEach((schedule) {
    //   // Extract schedule data
    //   var data = schedule.data() as Map<String, dynamic>;
    //   if (data["timestamp"] != null &&
    //       DateFormat('MMM d, y h:mm a ss').format(
    //         (data["timestamp"] as Timestamp).toDate(),
    //       ) == DateFormat('MMM d, y h:mm a ss').format(
    //         now.subtract(Duration(seconds: 4)),
    //       )) {
    //     DatabaseReference userRef = FirebaseDatabase.instance.ref('User/'+data['senderId']);
    //     userRef.once().then((userData) {
    //       Map<String, dynamic> userMap = Map<String, dynamic>.from(userData.snapshot.value as Map);
    //       var name = userMap['userName'];
    //       var note = data['text'];
    //       _scheduleNotification2(name, note, "message%^&"+userMap['userName']+"%^&"+userMap['profile']+"%^&"+userMap['email']+"%^&"+userMap['uid']);
    //       _addNotificationToFirestore2(name, note, "message", userMap['uid']);
    //     }).catchError((err) {
    //       log(err);
    //     });
    //   }
    // });

  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      var data = payload.split("%^&");
      switch(data[0]) {
        case "message":
          // PersistentNavBarNavigator.pushNewScreen(
          //   context,
          //   screen: MessagesScreen(
          //       name: data[1],
          //       image: data[2],
          //       email: data[3],
          //       receiverId: data[4]
          //   ),
          //   withNavBar: false, // Set this to true to include the persistent navigation bar
          // );

          break;
        case "task":
          // controller.index = 1;
          break;
        // case "note":
        //   DocumentSnapshot<Map<String, dynamic>> noteSnapshot = await FirebaseFirestore.instance
        //       .collection('Notes')
        //       .doc(data[1])
        //       .get();
        //
        //   Map<String, dynamic>? noteData = noteSnapshot.data();
        //
        //   if (noteData != null) {
        //     PersistentNavBarNavigator.pushNewScreen(
        //       context,
        //       screen: EditNotesScreen(noteDocument: noteData),
        //       withNavBar: false, // Set this to true to include the persistent navigation bar
        //     );
        //   } else {
        //     print('Note data is null');
        //   }
        //   break;
      }
    }
  }

  // Future<void> _addNotificationToFirestore2(String title, String message, String type, String itemID) async {
  //   await notificationCollection.add({
  //     'title': title,
  //     'message': message,
  //     'userUID': userUID,
  //     'timeAdded': Timestamp.fromDate(DateTime.now()),
  //     'type': type,
  //     'itemID': itemID
  //   });
  // }

  // Future<void> _scheduleNotification2(String title, String message, String data) async {
  //   // Define the Android notification channel
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'channel_id', // Channel ID
  //     'Channel Name', // Channel Name
  //     description: 'Channel Description', // Channel Description
  //     importance: Importance.max, // Importance level
  //   );
  //
  //   // Create the Android notification details with the defined channel
  //   final AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //     'channel_id', // Same Channel ID as defined above
  //     'Channel Name', // Same Channel Name as defined above
  //     channelDescription: 'Channel Description', // Same Channel Description as defined above
  //     importance: Importance.max,
  //   );
  //
  //   // Create the iOS notification details
  //   const DarwinNotificationDetails iOSPlatformChannelSpecifics =
  //   DarwinNotificationDetails();
  //
  //   // Combine both Android and iOS notification details into one NotificationDetails object
  //   final NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );
  //
  //   // Schedule the notification using the configured channel
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     title,
  //     message,
  //     tz.TZDateTime.from(DateTime.now(), tz.local),
  //     platformChannelSpecifics,
  //     uiLocalNotificationDateInterpretation:
  //     UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //   );
  //
  //   flutterLocalNotificationsPlugin.show(0, title, message, platformChannelSpecifics, payload: data);
  // }

  Future<void> _scheduleNotification(String title, String message) async {
    // Define the Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id', // Channel ID
      'Channel Name', // Channel Name
      description: 'Channel Description', // Channel Description
      importance: Importance.max, // Importance level
    );

    // Create the Android notification details with the defined channel
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id', // Same Channel ID as defined above
      'Channel Name', // Same Channel Name as defined above
      channelDescription: 'Channel Description', // Same Channel Description as defined above
      importance: Importance.max,
    );

    // Create the iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails();

    // Combine both Android and iOS notification details into one NotificationDetails object
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Schedule the notification using the configured channel
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      message,
      tz.TZDateTime.from(DateTime.now(), tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    flutterLocalNotificationsPlugin.show(0, title, message, platformChannelSpecifics);
  }

  Future<void> _addNotificationToFirestore(String title, String message) async {
    await notificationCollection.add({
      'title': title,
      'message': message,
      'userUID': userUID,
      'timeAdded': Timestamp.fromDate(DateTime.now())
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: PreferredSize(
          child: getAppBar(), preferredSize: Size.fromHeight(60)),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: getBody(),
      ),
    );
  }

  Widget getAppBar() {
    return AppBar(
      shape: RoundedRectangleBorder(),
      elevation: 0,
      backgroundColor: Color(0xFFe5f3fd),
      title: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "EduVantage",
              style: TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            userProfile != null && userProfile != "" ?
            RawMaterialButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ProfileScreen(userUID: userUID),
                  withNavBar: false,
                );
              },
              constraints: BoxConstraints.expand(width: 35, height: 35),
              shape: CircleBorder(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: userProfile!,
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    CupertinoIcons.person_alt_circle_fill,
                    color: Colors.black87.withOpacity(0.9),
                    size: 35,
                  ),
                ),
              ),
            )
                :
            IconButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ProfileScreen(userUID: userUID),
                  withNavBar: false,
                );
              },
              icon: Icon(
                CupertinoIcons.person_alt_circle_fill,
                color: Colors.black87.withOpacity(0.9),
                size: 35,
              ),
            ),

          ],
        ),
      ),
    );
  }

Widget getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 17),
                child: IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black, size: 24,),
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: NotificationScreen(userUID: this.userUID),
                      withNavBar: false,
                    );
                  },
                ),
              ),
            ),
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: EdgeInsets.only(right: 17),
            //     child: Stack(
            //       children: [
            //         IconButton(
            //           icon: Icon(Icons.notifications, color: Colors.black, size: 24,),
            //           onPressed: () {
            //             PersistentNavBarNavigator.pushNewScreen(
            //               context,
            //               screen: NotificationScreen(userUID: widget.userUID),
            //               withNavBar: false,
            //             );
            //             // Assuming you've read the notifications and there are no new notifications
            //             setState(() {
            //               hasNewNotification = false;
            //             });
            //           },
            //         ),
            //         if (hasNewNotification)
            //           Positioned(
            //             right: 8,
            //             top: 8,
            //             child: Container(
            //               width: 8,
            //               height: 8,
            //               decoration: BoxDecoration(
            //                 color: Colors.red, // You can change the color as needed
            //                 shape: BoxShape.circle,
            //               ),
            //             ),
            //           ),
            //       ],
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Class Schedule",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: classCollection
                            .where('userUID', isEqualTo: userUID)
                            .orderBy('startTime')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'No classes available',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: buildAddClassButton(),
                                ),
                              ],
                            );
                          }

                          final classScheduleItems = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final documentId = doc.id;
                            final backgroundColor =
                            Color(int.parse(data['backgroundColor'], radix: 16));
                            return {
                              'documentId': documentId,
                              'subject': data['subjectName'],
                              'subjectCode': data['subjectCode'],
                              'startTime': data['startTime'],
                              'endTime': data['endTime'],
                              'room': data['room'],
                              'teacher': data['teacher'],
                              'backgroundColor': backgroundColor,
                            };
                          }).toList();

                          // Sort the classScheduleItems based on startTime
                          classScheduleItems.sort((a, b) {
                            var startTimeA = a['startTime'];
                            var startTimeB = b['startTime'];
                            return startTimeA.compareTo(startTimeB);
                          });

                          // Now build the list of widgets
                          final classWidgets = classScheduleItems.map((classItem) {
                            return buildClassScheduleItem(
                              documentId: classItem['documentId'],
                              subject: classItem['subject'],
                              subjectCode: classItem['subjectCode'],
                              startTime: classItem['startTime'],
                              endTime: classItem['endTime'],
                              room: classItem['room'],
                              teacher: classItem['teacher'],
                              backgroundColor: classItem['backgroundColor'],
                              context: context
                            );
                          }).toList();

                          // Add the "Add Class" button at the end
                          classWidgets.add(buildAddClassButton());

                          return Container(
                            height: 150,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: classWidgets,
                            ),
                          );
                        },
                      )

                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "Attached Tasks",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: taskCollection
                              .where('userUID', isEqualTo: userUID)
                              .where('pinned', isEqualTo: true)
                              .orderBy('date') // Sort by date in ascending order
                              .orderBy('startTime', descending: false) // Then sort by startTime in ascending order
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No pinned tasks available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }

                            // Convert QuerySnapshot to List
                            final List<DocumentSnapshot> tasks = snapshot.data!.docs;

                            // Sort the tasks based on startTime
                            tasks.sort((a, b) {
                              var startTimeA = a['startTime']; // Assuming 'startTime' is of type TimeOfDay
                              var startTimeB = b['startTime']; // Assuming 'startTime' is of type TimeOfDay
                              return startTimeA.compareTo(startTimeB);
                            });

                            // Build the UI with sorted tasks
                            final pinnedTasks = tasks.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final taskId = doc.id;
                              final type = data['taskType'];
                              final date = data['date'].toDate();
                              final startTime = TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['startTime']));
                              final endTime = TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['endTime']));
                              final subject = data['subjectName'];
                              final subjectCode = data['subjectCode'];
                              final teacher = data['teacher'];
                              final description = data['description'];
                              final backgroundColor = Color(int.parse(data['backgroundColor'], radix: 16));
                              final pinned = data['pinned'];
                              final isDone = data['isDone'] ?? false;

                              return buildTaskItem(
                                  taskId: taskId,
                                  type: type,
                                  date: date,
                                  startTime: startTime,
                                  endTime: endTime,
                                  subject: subject,
                                  subjectCode: subjectCode,
                                  teacher: teacher,
                                  description: description,
                                  backgroundColor: backgroundColor,
                                  pinned: pinned,
                                  isDone: isDone,
                                  context: context
                              );
                            }).toList();

                            return Column(
                              children: pinnedTasks,
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClassScheduleItem({
    required String documentId,
    required String subject,
    required String subjectCode,
    required Timestamp startTime,
    required Timestamp endTime,
    required String room,
    required String teacher,
    required Color backgroundColor,
    required BuildContext context, // Add BuildContext parameter
  }) {
    final startTimeDt = startTime.toDate();
    final endTimeDt = endTime.toDate();
    bool isWithinCurrentTime = DateTime.now().isAfter(startTimeDt) &&
        DateTime.now().isBefore(endTimeDt);

    void onTap() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius:
              BorderRadius.circular(15)
          ),
          title: Text('Class Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.book, size: 14,),
                  SizedBox(width: 4),
                  Text(
                    'Subject:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$subject',
                      maxLines: 1, // Limit to one line
                      overflow: TextOverflow.ellipsis, // Add ellipsis if overflow
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.book_outlined, size: 14,),
                  SizedBox(width: 4),
                  Text(
                    'Subject Code:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$subjectCode',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_filled, size: 14,),
                  SizedBox(width: 4),
                  Text(
                    'Start Time:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${DateFormat('h:mm a').format(startTimeDt)}',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14,),
                  SizedBox(width: 4),
                  Text(
                    'End Time:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${DateFormat('h:mm a').format(endTimeDt)}',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.room, size: 14,),
                  SizedBox(width: 4),
                  Text(
                    'Room:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$room',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Teacher:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$teacher',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.red),),
            ),
          ],
        ),
      );
    }

    // Calculate color luminance to determine text color
    double luminance = backgroundColor.computeLuminance();
    Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
    Color borderColor = luminance > 0.5 ? Colors.black : Colors.yellow.shade800;

    StreamSubscription? subscription;
    Timer? timer;
    StreamController<bool> streamController = StreamController<bool>();

    void updateWithinCurrentTime() {
      streamController.add(DateTime.now().isAfter(startTimeDt) &&
          DateTime.now().isBefore(endTimeDt));
    }

    subscription = streamController.stream.listen((bool isWithinTime) {
      setState(() {
        isWithinCurrentTime = isWithinTime;
      });
    });

    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      updateWithinCurrentTime();
    });

    // Cancel the subscription and timer when the widget is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subscription?.cancel();
      timer?.cancel();
    });

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          border: isWithinCurrentTime
              ? Border.all(
            color: borderColor, // Change border color as needed
            width: 3,
          )
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right:25),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          subjectCode,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        color: textColor,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Start: ${DateFormat('h:mm a').format(startTimeDt)}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: textColor,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'End: ${DateFormat('h:mm a').format(endTimeDt)}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 1,
              right: 1,
              child: PopupMenuButton(
                color: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: textColor,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: EditClassScreen(docId: documentId, userUID: userUID),
                      withNavBar: false,
                    );
                  } else if (value == 'delete') {
                    deleteClass(documentId);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular),),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular),),
                    ),
                  ];
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      room.length <= 11 ? room : '${room.substring(0, 11)}...',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      teacher.length <= 11 ? teacher : '${teacher.substring(0, 11)}...',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddClassButton() {
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: CreateNewClassScreen(),
          withNavBar: false,
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.bgColor,
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }

  void deleteClass(String documentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        title: Text('Delete Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
        content: Text('Are you sure you want to delete this class?', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.red),),
          ),
          TextButton(
            onPressed: () {
              classCollection.doc(documentId).delete();
              Navigator.of(context).pop();
              Utils.toastMessage('Class deleted successfully');
            },
            child: Text('Delete', style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.black87),),
          ),
        ],
      ),
    );
  }

  Widget buildTaskItem({
    required String taskId,
    required String type,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String subject,
    required String subjectCode,
    required String teacher,
    required String description,
    required Color backgroundColor,
    required bool pinned,
    required bool isDone,
    required BuildContext context, // Add BuildContext parameter
  }) {

    void showTaskDetailsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              'Task Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 14,),
                      SizedBox(width: 4),
                      Text(
                        'Type:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$type',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.book, size: 14,),
                      SizedBox(width: 4),
                      Text(
                        'Subject:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${subject ?? 'No Subject'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.book_outlined, size: 14,),
                      SizedBox(width: 4),
                      Text(
                        'Subject Code:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${subjectCode ?? 'No Code'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14,),
                      SizedBox(width: 4),
                      Text(
                        'Teacher:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${teacher ?? 'No Teacher'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 14,),
                      SizedBox(width: 4),
                      Text(
                        'Date:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(date ?? DateTime.now())}',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.alarm,size: 14,),
                      SizedBox(width: 4),
                      Text(
                        'Time:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${startTime.format(context) ?? 'N/A'} - ${endTime.format(context) ?? 'N/A'}',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description, size: 14),
                      SizedBox(width: 4),
                      Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (description.contains('http') || description.contains('www')) {
                              _launchURL(description);
                            }
                          },
                          child: Text(
                            '${description ?? 'No Description'}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: description.contains('http') || description.contains('www')
                                  ? Colors.blue
                                  : Colors.black, // Set color to blue only if it contains a link
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close', style: TextStyle(color: Colors.red, fontSize: 14, fontFamily: AppFonts.alatsiRegular),),
              ),
            ],
          );

        },
      );
    }

    // Calculate color luminance to determine text color
    double luminance = backgroundColor.computeLuminance();
    Color textColor = luminance > 0.5 ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: showTaskDetailsDialog,
      child: Container(
        width: 350,
        margin: EdgeInsets.all(9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row (
                    children: [
                      Text(
                        '${type}',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.5
                        ),
                      ),
                      SizedBox(width: 10),
                      if (isDone)
                        Icon(Icons.check_circle, color: textColor, size: 20),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${subject ?? 'No Subject'}',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        height: 1
                    ),
                  ),
                  Text(
                    '${subjectCode ?? 'No Code'}',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.1
                    ),
                  ),
                  Text(
                    '${teacher ?? 'No Teacher'}',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 13,
                        color: textColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        DateFormat('MMM dd, yyyy').format(date ?? DateTime.now()),
                        style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            height: 1
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 13,
                        color: textColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${startTime.format(context) ?? 'N/A'} - ${endTime.format(context) ?? 'N/A'}',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            height: 1
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    description ?? 'No Description',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 1,
              right: 1,
              child: PopupMenuButton(
                color: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: textColor,
                ),
                onSelected: (value) {
                  if (value == 'unpin') {
                    unpinTask(taskId);
                  } else if (value == 'Mark as Done') {
                    markAsDone(taskId);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'unpin',
                      child: Text('Unpin', style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.white),),
                    ),
                    if(!isDone)
                      PopupMenuItem(
                        value: 'Mark as Done',
                        child: Text('Mark as Done', style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.white),),
                      ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch a URL
  void _launchURL(String url) async {
    try {
      if (await launchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.platformDefault );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Handle the error gracefully, such as showing a snackbar or toast message
      Utils.toastMessage("Error opening link");
    }
  }

  void unpinTask(String taskId) {
    taskCollection.doc(taskId).update({'pinned': false})
        .then((value) {
      // Task has been successfully unpinned
    }).catchError((error) {
      print("Error unpinning task: $error");
    });
  }

}
