import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/view/dashboard/chat/user/User_Interests.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tech_media/view/dashboard/chat/messages_screen.dart';

import '../../profile/ProfileScreen2.dart';

Key key = Key(Random().nextInt(1000000).toString());

class UserListScreen extends StatefulWidget {
  final String userUID;
  UserListScreen({required this.userUID});
  @override
  _UserListScreenState createState() => _UserListScreenState(userUID: userUID);
}

class _UserListScreenState extends State<UserListScreen> {
  bool isDialogOpen = false; // Track dialog state
  final String userUID;
  int completedTasksCount = 0;
  _UserListScreenState({required this.userUID});
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');
  final CollectionReference messageCollection =
  FirebaseFirestore.instance.collection('messages');
  String filter = ""; // Search filter string
  String? selectedDepartment; // Selected department
  String? selectedCourse; // Selected course
  List<Map<String, dynamic>> latestMessage = [];

  @override
  void initState() {
    super.initState();
    key = Key(Random().nextInt(1000000).toString());
    listLatestMessages();
  }

  Future<void> checkTasksCompletion() async {
    try {
      // Simulate fetching data
      await Future.delayed(Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userUID', isEqualTo: userUID)
          .get();

      setState(() {
        completedTasksCount = querySnapshot.docs
            .where((doc) =>
        doc.data() != null &&
            (doc.data() as Map<String, dynamic>).containsKey('isDone') &&
            (doc.data() as Map<String, dynamic>)['isDone'] == true)
            .length;
      });
    } catch (error) {
      print('Error fetching tasks data: $error');
      // Handle error accordingly
    }
  }

  // @override
  // void setState(fn) {
  //   if (mounted) {
  //     super.setState(fn);
  //     listLatestMessages();
  //   }
  // }

  // Define courses mapped to each department
  final Map<String, List<String>> coursesByDepartment = {
    'CAS': ['BS Architecture', 'BS Civil Engineering', 'BS Computer Engineering',
      'BS Electronics Engineering', 'BS Electrical Engineering',
      'BS Mechanical Engineering', 'BA Communication', 'BA Political Science', 'Bachelor of Elementary Education',
      'BSED - Science', 'BSED - Social Studies',
      'BSED - English', 'BSED - Math', 'BS Information Technology', 'Associate in Computer Technology', 'BS Accountancy', 'BS AIS (AcctgTech)', 'BS Management Accounting',
      'BSBA - Financial Management', 'BSBA - Marketing Management',
      'BS Tourism Management', 'BS Hospitality Management', 'BS Medical Laboratory', 'BS Nursing', 'BS Pharmacy', 'BS Psychology', 'BS Criminology' ],

    'CEA': ['BS Architecture', 'BS Civil Engineering', 'BS Computer Engineering',
      'BS Electronics Engineering', 'BS Electrical Engineering',
      'BS Mechanical Engineering'],

    'CELA': ['BA Communication', 'BA Political Science', 'Bachelor of Elementary Education',
      'BSED - Science', 'BSED - Social Studies',
      'BSED - English', 'BSED - Math'],

    'CITE' : ['BS Information Technology', 'Associate in Computer Technology'],

    'CMA': ['BS Accountancy', 'BS AIS (AcctgTech)', 'BS Management Accounting',
      'BSBA - Financial Management', 'BSBA - Marketing Management',
      'BS Tourism Management', 'BS Hospitality Management'],

    'CAHS': ['BS Medical Laboratory', 'BS Nursing', 'BS Pharmacy', 'BS Psychology'],

    'CCJE': ['BS Criminology'],
  };

  // Function to handle the pull-to-refresh action
  Future<void> _refreshData() async {
    await listLatestMessages();
    setState(() {
      key = Key(Random().nextInt(1000000).toString());
    });
  }

  Future<void> listLatestMessages() async {
    try {
      QuerySnapshot messages = await FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true) // Sort messages by timestamp in descending order
          .get();
      List<Map<String, dynamic>> newLatestMessageList = [];

      messages.docs.forEach((message) {
        if (message['senderId'] == userUID || message['receiverId'] == userUID) {
          newLatestMessageList.add(message.data() as Map<String, dynamic>);
        }
      });
      setState(() {
        latestMessage = newLatestMessageList;
      });
    } catch (e) {
      print('Error listing latest messages: $e');
    }
  }

  DateTime? getLatestMessageDate(String userId) {
    try {
      List<Map<String, dynamic>> filteredMessages = latestMessage.where((element) {
        return element['senderId'] == userId || element['receiverId'] == userId;
      }).toList();

      filteredMessages.sort((a,b) {
        return b['timestamp'].toString().compareTo(a['timestamp'].toString());
      });

      if (filteredMessages.isNotEmpty) {
        return filteredMessages[0]['timestamp'].toDate();
      }
      return null;
    } catch (e) {
      print('Error fetching latest message date: $e');
      return null;
    }
  }

  // Inside your _UserListScreenState class

  Future<void> fetchUsersWithBadge() async {

    if (isDialogOpen) return; // Prevent multiple dialogs from opening

    setState(() {
      isDialogOpen = true;
    });

    try {
      // Fetch users with completed tasks count >= 3 from Firebase
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('isDone', isEqualTo: true)
          .get();

      List<String> usersWithBadge = []; // List to store user IDs with the badge

      // Iterate through tasks to count completed tasks per user
      Map<String, int> completedTasksCountPerUser = {};
      querySnapshot.docs.forEach((taskDoc) {
        String userId = taskDoc['userUID'];
        completedTasksCountPerUser[userId] = (completedTasksCountPerUser[userId] ?? 0) + 1;
      });

      // Add users with completed tasks >= 3 to usersWithBadge list
      completedTasksCountPerUser.forEach((userId, count) {
        if (count >= 20) {
          usersWithBadge.add(userId);
        }
      });

      // Show dialog with users having the badge
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.indigo,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Task Masters',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: CupertinoColors.white, // Background color of the container
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.calendar_today, // Change the icon to your desired icon
                        color: Colors.indigo,
                        size: 18,// Change the color as needed
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (String userId in usersWithBadge)
                    FutureBuilder<DatabaseEvent>(
                      future: FirebaseDatabase.instance.reference().child('User').child(userId).once(), // Assuming 'users' is your node in Realtime Database
                      builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('User not found');
                        }

                        var userData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                        return ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              _navigateToUserProfile(userId); // Call your navigation function when the image is tapped
                            },
                            child: Container(
                              height: 45 ,
                              width: 45,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: userData['profile'] ?? '',
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          title: Text(userData['userName'] ?? '', style: TextStyle(color: Colors.white),),
                          subtitle: Text(userData['department'] ?? '', style: TextStyle(color: Colors.white70),),
                          // You can display more user information here
                        );
                      },
                    ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Finish 20 tasks to be a Task Master',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ],
          );
        },
      );


      // Wait for the dialog to close
      await Future.delayed(Duration(milliseconds: 500)); // Adjust delay as needed

      setState(() {
        isDialogOpen = false;
      });
    } catch (error) {
      print('Error fetching users with badge: $error');
      // Handle error accordingly
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFe5f3fd),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          centerTitle: false,
          title: Text(
            'Contacts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: AppFonts.alatsiRegular,
            ),
          ),
          backgroundColor: Color(0xFFe5f3fd),
          elevation: 0,
          actions: [
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: IconButton(
                onPressed: () {
                  // Implement the action when "Chat with Admin" icon is pressed
                  _startChatWithAdmin(context);
                },
                icon: Icon(
                  Icons.admin_panel_settings,
                  size: 25,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: IconButton(
                onPressed: isDialogOpen ? null : fetchUsersWithBadge, // Disable button when dialog is open
                icon: Icon(
                  CupertinoIcons.bolt_badge_a_fill,
                  size: 25,
                  color: Colors.yellow.shade800,
                ),
              ),
            ),
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: IconButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: UserInterestScreen( userUID: userUID,
                    ),
                    withNavBar: false,
                  );
                },
                icon: Icon(
                  Icons.interests_rounded,
                  size: 25,
                  color: CupertinoColors.systemMint,
                ),
              ),
            ),
            SizedBox(width: 15,)
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.transparent),
                      color: Colors.white,  // Change the color here
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search a contact',
                          prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey,),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w100, fontSize: 18),
                        ),
                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w300),
                        onChanged: (value) {
                          setState(() {
                            filter = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Department selection buttons
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ['All', 'CAS', 'CEA', 'CELA', 'CITE', 'CMA', 'CAHS', 'CCJE'].length,
                      itemBuilder: (context, index) {
                        final department = ['All', 'CAS', 'CEA', 'CELA', 'CITE', 'CMA', 'CAHS', 'CCJE'][index];
                        return Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedDepartment = department == 'All' ? null : department;
                                selectedCourse = null; // Reset selected course when department changes
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0, backgroundColor: selectedDepartment == department ? Colors.red : Colors.black, // Change button color
                            ),
                            child: Text(
                              department,
                              style: TextStyle( // Change font style
                                color: Colors.white, // Change font color
                                fontFamily: AppFonts.alatsiRegular,
                                fontWeight: FontWeight.normal, // Change font weight
                                fontSize: 14, // Change font size
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                  SizedBox(height: 10),
                  // Course selection buttons
                  if (selectedDepartment != null)
                    SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: coursesByDepartment[selectedDepartment!]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final course = coursesByDepartment[selectedDepartment!]?[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCourse = course;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0, backgroundColor: selectedCourse == course ? CupertinoColors.systemMint : Colors.black54, // Change button color
                              ),
                              child: Text(
                                course ?? '',
                                style: TextStyle( // Change font style
                                  color: Colors.white, // Change font color
                                  fontFamily: AppFonts.alatsiRegular,
                                  fontWeight: FontWeight.normal, // Change font weight
                                  fontSize: 13, // Change font size
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData, // Callback when the user pulls to refresh
                child: FirebaseAnimatedList(
                  key: key,
                  query: ref.orderByChild('userName'), // Sort by username
                  sort: (a, b) {
                    DateTime? aDate = getLatestMessageDate(a.key.toString());
                    DateTime? bDate = getLatestMessageDate(b.key.toString());

                    if (aDate == null && bDate == null) {
                      return 0;
                    } else if (aDate == null) {
                      return 1;
                    } else if (bDate == null) {
                      return -1;
                    } else {
                      return bDate.compareTo(aDate);
                    }
                  },
                  itemBuilder: (context, snapshot, animation, index) {
                    if (SessionController().userId.toString() == snapshot.key) {
                      return Container(); // Exclude the current user
                    }
                    final userName = snapshot.child('userName').value?.toString() ?? "";
                    final email = snapshot.child('email').value?.toString() ?? "";
                    final image = snapshot.child('profile').value?.toString() ?? "";
                    final department = snapshot.child('department').value?.toString() ?? ""; // Retrieve department from Firebase
                    final course = snapshot.child('course').value?.toString() ?? ""; // Retrieve course from Firebase
                    final receiverId = snapshot.key ?? "";

                    // Check if the user's name contains the filter text
                    if ((userName.toLowerCase().contains(filter.toLowerCase()) ||
                        email.toLowerCase().contains(filter.toLowerCase())) &&
                        (selectedDepartment == null || department == selectedDepartment) &&
                        (selectedCourse == null || course == selectedCourse)) {
                      return _buildUserTile(
                        name: userName,
                        image: image,
                        email: email,
                        receiverId: receiverId,
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile({
    required String name,
    required String image,
    required String email,
    required String receiverId,
  }) {
    // Exclude the specific user by their user ID
    if (receiverId == '6K5yENRTbKQfYcyZS9hnzQfujjC2') {
      return Container(); // Return an empty container to exclude the user
    }

    // Find the latest message for the current user
    var latestMessageData = latestMessage.firstWhere(
          (element) =>
      element['senderId'] == receiverId || element['receiverId'] == receiverId,
      orElse: () => {},
    );

    String latestMessageText = latestMessageData['text'] ?? ''; // Extract the latest message text
    DateTime? latestMessageTimestamp =
    latestMessageData['timestamp']?.toDate(); // Extract the latest message timestamp

    String formattedTimestamp = _formatTimestamp(latestMessageTimestamp);

    return Card(
      elevation: 0, //for box
      color: Color(0xFFe5f3fd),
      child: ListTile(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MessagesScreen(
              name: name,
              image: image,
              email: email,
              receiverId: receiverId,
            ),
            withNavBar: false,
          );
        },
        leading: GestureDetector(
          onTap: () {
            // Navigate to the user's profile screen
            _navigateToUserProfile(receiverId);
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black87)],
              border: Border.all(color: Colors.pink),
            ),
            child: CachedNetworkImage(
              imageUrl: image, // The URL of the user's profile image
              placeholder: (context, url) =>
                  Icon(CupertinoIcons.person_alt, color: Colors.white),
              errorWidget: (context, url, error) =>
                  Icon(CupertinoIcons.person_alt, color: Colors.white),
              imageBuilder: (context, imageProvider) => ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
              ),
            ),
          ),
        ),
        title: Text(name, style: TextStyle(),),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, fontSize: 12),),
                  SizedBox(height: 1),
                  Text(
                    latestMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Text(
              formattedTimestamp,
              style: TextStyle(fontSize: 11.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToUserProfile(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ProfileScreen2(userId: userId),
      withNavBar: false, // Set this to true to include the persistent navigation bar
    );
  }

  void _startChatWithAdmin(BuildContext context) {
    DatabaseReference adminRef = FirebaseDatabase.instance.ref().child('User').child('6K5yENRTbKQfYcyZS9hnzQfujjC2'); // Assuming '6K5yENRTbKQfYcyZS9hnzQfujjC2' is the admin's UID

    // Use onData callback to handle the database event
    adminRef.once().then((DatabaseEvent event) {
      DataSnapshot? dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        dynamic data = dataSnapshot.value;
        if (data is Map) {
          String adminName = data['userName'] ?? '';
          String adminImage = data['profile'] ?? '';
          String adminEmail = 'eduvantagea@gmail.com'; // You can fetch admin's email from the database if available

          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MessagesScreen(
              receiverId: '6K5yENRTbKQfYcyZS9hnzQfujjC2',
              name: adminName,
              image: adminImage,
              email: adminEmail,
            ),
            withNavBar: false,
          );
        }
      }
    }).catchError((error) {
      print('Error fetching admin data: $error');
      // Handle error here, such as displaying a message to the user
    });
  }


  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (timestamp.isAfter(today)) {
      return DateFormat.jm().format(timestamp); // Show time if it's today
    } else if (timestamp.isAfter(yesterday)) {
      return 'Yesterday '; // Show yesterday and time
    } else {
      final formatString = timestamp.year == now.year
          ? 'MMMM dd'
          : 'MMMM dd, yyyy';
      return DateFormat(formatString).format(timestamp); // Show month, day, and time with or without year
    }
  }

  // String _formatTimestamp(DateTime? timestamp) {
  //   if (timestamp == null) {
  //     return '';
  //   }
  //
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   final yesterday = DateTime(now.year, now.month, now.day - 1);
  //
  //   if (timestamp.isAfter(today)) {
  //     return DateFormat.jm().format(timestamp); // Format: 6:00 PM
  //   } else if (timestamp.isAfter(yesterday)) {
  //     return 'Yesterday'; // Show 'Yesterday' for timestamps from yesterday
  //   } else {
  //     return DateFormat.yMMMMd().format(timestamp); // Format: March 16, 2023
  //   }
  // }
}