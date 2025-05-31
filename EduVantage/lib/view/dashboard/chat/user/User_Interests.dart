import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tech_media/view/dashboard/chat/messages_screen.dart';

import '../../profile/ProfileScreen2.dart';

Key key = Key(Random().nextInt(1000000).toString());

class UserInterestScreen extends StatefulWidget {
  final String userUID;
  UserInterestScreen({required this.userUID});
  @override
  _UserInterestScreenState createState() =>
      _UserInterestScreenState(userUID: userUID);
}

class _UserInterestScreenState extends State<UserInterestScreen> {
  final String userUID;
  _UserInterestScreenState({required this.userUID});
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');
  final CollectionReference messageCollection =
  FirebaseFirestore.instance.collection('messages');
  String filter = ""; // Search filter string
  List<Map<String, dynamic>> latestMessage = [];
  List<String> selectedInterests = []; // Selected interests by the user

  final List<String> interests = [
    'Sports',
    'Music',
    'Reading',
    'Art',
    'Science',
    'Technology',
    'Cooking',
    'Gaming',
    'Fashion',
    'Fitness',
    'Literature',
    'Movies',
    'History',
    'Photography',
    'Programming',
  ];

  @override
  void initState() {
    super.initState();
    key = Key(Random().nextInt(1000000).toString());
    listLatestMessages();
  }

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

      filteredMessages.sort((a, b) {
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
            'Study Buddy',
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list_rounded, color: CupertinoColors.systemMint),
                    onPressed: () {
                      // Show a dialog to select interests
                      _showInterestsDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 15,),
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
                      color: Colors.white, // Change the color here
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search a contact',
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w100,
                              fontSize: 18),
                        ),
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w300),
                        onChanged: (value) {
                          setState(() {
                            filter = value;
                          });
                        },
                      ),
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
                    final userName =
                        snapshot.child('userName').value?.toString() ?? "";
                    final email =
                        snapshot.child('email').value?.toString() ?? "";
                    final image =
                        snapshot.child('profile').value?.toString() ?? "";
                    final interests =
                    List<String>.from((snapshot.child('interests').value as Iterable<dynamic>?) ?? []);

                    final receiverId = snapshot.key ?? "";

                    // Check if the user's name contains the filter text and interests match
                    if ((userName.toLowerCase().contains(filter.toLowerCase()) ||
                        email.toLowerCase().contains(filter.toLowerCase())) &&
                        (selectedInterests.isEmpty || interests.toSet().intersection(selectedInterests.toSet()).isNotEmpty)) {
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
      element['senderId'] == receiverId ||
          element['receiverId'] == receiverId,
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
        title: Text(
          name,
          style: TextStyle(),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  SizedBox(height: 1),
                  Text(
                    latestMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: Colors.black87),
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

  void _showInterestsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 0,
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              title: Text('Select Interests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),),
              content: SingleChildScrollView(
                child: Column(
                  children: interests.map((interest) {
                    return CheckboxListTile(
                      side: WidgetStateBorderSide.resolveWith(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const BorderSide(color: Colors.white, width: 2);
                          }
                          return const BorderSide(color: Colors.white70, width: 2);
                        },
                      ),
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        ),
                        activeColor: CupertinoColors.black,
                        checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      title: Text(interest, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,  color: Colors.white),),
                      value: selectedInterests.contains(interest),
                      onChanged: (value) {
                        setState(() {
                          if (value != null && value) {
                            selectedInterests.add(interest);
                          } else {
                            selectedInterests.remove(interest);
                          }
                          print('Selected Interests: $selectedInterests'); // Debugging
                          // Apply filter immediately after selecting interests
                          // without needing to refresh the screen
                          _applyFilter();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    print('Apply Button Pressed'); // Debugging
                    // Apply filter immediately after selecting interests
                    // without needing to refresh the screen
                    // _applyFilter();
                  },
                  child: Text('Apply', style: TextStyle(color: CupertinoColors.white, fontFamily: AppFonts.alatsiRegular,),),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _applyFilter() {
    setState(() {
      key = Key(Random().nextInt(1000000).toString()); // Refresh the FirebaseAnimatedList
    });
  }


}
