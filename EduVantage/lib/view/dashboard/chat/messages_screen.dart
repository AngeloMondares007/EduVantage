import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/chat/user/user_list_screen.dart' as UserList;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher_string.dart';

import '../../../res/components/CircularProgress.dart';
import '../profile/ProfileScreen2.dart';

class MessagesScreen extends StatefulWidget {
  final String name;
  final String image;
  final String email;
  final String receiverId;

  MessagesScreen({
    required this.name,
    required this.image,
    required this.email,
    required this.receiverId,
  });

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  DateTime? selectedTimeStamp;
  var _imageFile;

  void _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showCameraOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(CupertinoIcons.photo_fill_on_rectangle_fill, color: Colors.blue.shade800,),
                title: Text('Select Image', style: TextStyle(fontWeight: FontWeight.normal),),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage();
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.photo_camera_solid, color: Colors.green.shade800,),
                title: Text('Take Picture', style: TextStyle(fontWeight: FontWeight.normal),),
                onTap: () {
                  Navigator.pop(context);
                  _takePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _navigateToUserProfile(String receiverId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ProfileScreen2(userId: receiverId),
      withNavBar: false, // Set this to true to include the persistent navigation bar
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: GestureDetector(
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black87)],
                  border: Border.all(color: Colors.pink),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the user's profile screen
                    _navigateToUserProfile(widget.receiverId);
                  },
                  child: CachedNetworkImage(
                    imageUrl: widget.image, // The URL of the user's profile image
                    placeholder: (context, url) => Icon(CupertinoIcons.person_alt, color: Colors.white, size: 15,),
                    errorWidget: (context, url, error) => Icon(CupertinoIcons.person_alt, color: Colors.white, size: 15),
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image(
                        fit: BoxFit.cover,
                        image: imageProvider,
                      ),
                    ),
                  ),
                ),
              ),
              // CircleAvatar(
              //   backgroundImage: CachedNetworkImage(widget.image, placeholder: (context, url) => Icon(CupertinoIcons.person_alt, color: Colors.white),),
              //   radius: 18,
              // ),
              SizedBox(width: 10),
              Text(widget.name),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .where('receiverId', isEqualTo: widget.receiverId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> senderSnapshot) {
                if (senderSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (senderSnapshot.hasError) {
                  return Center(child: Text('Error: ${senderSnapshot.error}'));
                }

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('senderId', isEqualTo: widget.receiverId)
                      .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> receiverSnapshot) {
                    if (receiverSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (receiverSnapshot.hasError) {
                      return Center(child: Text('Error: ${receiverSnapshot.error}'));
                    }

                    List<QueryDocumentSnapshot> messages = [];
                    messages.addAll(senderSnapshot.data!.docs);
                    messages.addAll(receiverSnapshot.data!.docs);

                    messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = messages[index].data() as Map<String, dynamic>;
                        bool isSender = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                        bool isSeen = data['isSeen'] ?? false;

                        return GestureDetector(
                          onLongPress: () {
                            if (isSender) {
                              _showDeleteConfirmationDialog(messages[index].id);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isSender)
                                CircleAvatar(
                                  backgroundImage: NetworkImage(widget.image),
                                  radius: 10,
                                ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isSender)
                                      Text(
                                        widget.name,
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ChatBubble(
                                      clipper: ChatBubbleClipper5(
                                        type: isSender ? BubbleType.sendBubble : BubbleType.receiverBubble,
                                      ),
                                      alignment: isSender ? Alignment.topRight : Alignment.bottomLeft,
                                      margin: EdgeInsets.only(top: 8),
                                      backGroundColor: isSender ? Colors.blueAccent : Colors.black.withOpacity(0.9),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //   data['text'],
                                          //   style: TextStyle(color: isSender ? Colors.white : Colors.white),
                                          // ),
                                          GestureDetector(
                                            onTap: () {
                                              if (data['text'] != null && containsUrl(data['text'])) {
                                                _launchURL(data['text']); // Call _launchURL when the text is tapped
                                              }
                                            },
                                            child: Text(
                                              data['text'] ?? '${widget.name} sent a photo',
                                              style: TextStyle(color: isSender ? Colors.white : Colors.white),
                                            ),
                                          ),
                          
                                          // if (!isSender && !isSeen)
                                          //   Text('Seen', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                          Text(
                                            _formatTimestamp(data['timestamp'].toDate()),
                                            style: TextStyle(color: Colors.white38, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if(data['imageUrl'] != null)
                                      Column(
                                        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _showFullImage(data['imageUrl']);
                                            },
                                            child: Padding(
                                                padding: EdgeInsetsDirectional.symmetric(vertical: 5),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Image(image: NetworkImage(data['imageUrl']), width: 200,)
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageFile != null) ...[
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 15.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.cover),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red,),
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xFFe5f3fd), // Background color of the container
                        ),
                        child: IconButton(
                          onPressed: _showCameraOptions,
                          icon: Icon(CupertinoIcons.photo_fill_on_rectangle_fill, size: 18, color: Colors.blueAccent,),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 120.0, // Adjust the max height as needed
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: TextField(
                                  controller: _textEditingController,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  cursorColor: Colors.blueAccent,
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 25,
                        color: Colors.blueAccent,
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                      SizedBox(width: 5,)
                    ],
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 3,)
        ],
      ),
    );
  }

  // Function to check if the message contains a URL
  bool containsUrl(String message) {
    return message.contains('http') || message.contains('www');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL')),
      );
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close the dialog when tapped
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain, // Adjust the fit as needed
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  // Function to format the timestamp based on the current date
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.year != timestamp.year) {
      // If the year is different, display the full date
      return DateFormat.yMMMd().add_jm().format(timestamp);
    } else if (now.day != timestamp.day) {
      // If the day is different (not today), display only the day and time
      return DateFormat.MMMd().add_jm().format(timestamp);
    } else {
      // If it's today, display only the time
      return DateFormat.jm().format(timestamp);
    }
  }
  bool _isSendingMessage = false;

  void _showDeleteConfirmationDialog(String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          elevation: 0,
          title: Text('Remove Message', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 24),),
          content: Text('Are you sure you want to remove this message?', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 14),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.red),),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance.collection('messages').doc(messageId).delete();
      print('Message deleted successfully');
    } catch (error) {
      print('Error deleting message: $error');
    }
  }


  void _sendMessage() async {
    if (_isSendingMessage) {
      return; // Prevent sending multiple messages simultaneously
    }

    String message = _textEditingController.text.trim();
    if (message.isNotEmpty || _imageFile != null) {
      setState(() {
        _isSendingMessage = true;
      });

      String senderId = FirebaseAuth.instance.currentUser?.uid ?? "Unknown sender";
      print("Sending message: '$message' from sender with ID: $senderId to receiver with ID: ${widget.receiverId}");

      // Show progress dialog while the message is being sent
      ProgressDialog.show(context, message: 'Sending message...',icon: Icons.send);

      try {
        String? imageUrl;

        if (_imageFile != null) {
          final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch.toString()}');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Hide progress dialog when done
        ProgressDialog.hide(context);

        // Ensure that the timestamp is not null
        Timestamp timestamp = Timestamp.now();

        Map<String, dynamic> messageData = {
          'senderId': senderId,
          'receiverId': widget.receiverId,
          'timestamp': timestamp,
          'isSeen': false
        };

        if (message.isNotEmpty) {
          messageData['text'] = message;
        }

        if (imageUrl != null) {
          messageData['imageUrl'] = imageUrl;
        }

        await FirebaseFirestore.instance.collection('messages').add(messageData);

        _textEditingController.clear();
        setState(() {
          _imageFile = null;
        });

        print("Message sent successfully");
        UserList.key = Key(Random().nextInt(1000000).toString());
      } catch (error) {
        print("Error sending message: $error");
      } finally {
        setState(() {
          _isSendingMessage = false;
        });
      }
    } else {
      print("Message is empty, not sending.");
    }
  }


}
