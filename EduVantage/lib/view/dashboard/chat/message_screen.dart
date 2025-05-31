import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/res/color.dart';

class MessageScreen extends StatefulWidget {
  final String image, name, email, receiverId;
  const MessageScreen({
    Key? key,
    required this.name,
    required this.image,
    required this.email,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child('Chat');
  final messageController = TextEditingController();
  List<ChatMessage> chatMessages = []; // List to store chat messages

  @override
  void initState() {
    super.initState();
    ref.onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data is Map<String, dynamic>) {
        setState(() {
          chatMessages.add(ChatMessage.fromMap(data));
          print("New chat message: ${data['message']}");
        });
      } else {
        print("Received invalid data from Firebase: $data");
      }
    });

    chatMessages.forEach((message) {
      print("Received message from Firebase: ${message.message}");
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        elevation: 0, // for shadow
        leading: const BackButton(
          color: AppColors.bgColor,
        ),
        backgroundColor: Color(0xFFe5f3fd),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.image),
              radius: 18,
            ),
            SizedBox(width: 16),
            Text(widget.name),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(
                    message: chatMessages[index].message,
                    isMe: chatMessages[index].sender == SessionController().userId.toString(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: messageController,
                        cursorColor: AppColors.primaryColor,
                        showCursor: false,
                        cursorHeight: 18,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 0, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          contentPadding: const EdgeInsets.all(20),
                          suffixIcon: InkWell(
                            onTap: () {
                              sendMessage();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          hintStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            height: 0,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.alertColor),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                      ),
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

  void sendMessage() {
    if (messageController.text.isEmpty) {
      Utils.toastMessage('Enter message');
    } else {
      final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      print("Preparing to send message: ${messageController.text}");
      ref.child(timeStamp).set({
        'isSeen': false,
        'message': messageController.text.toString(),
        'sender': SessionController().userId.toString(),
        'receiver': widget.receiverId,
        'type': 'text',
        'time': timeStamp.toString(),
      }).then((value) {
        print("Message sent to Firebase: ${messageController.text}");
        messageController.clear(); // Move this line here
      }).catchError((error) {
        print("Error sending message to Firebase: $error");
      });
    }
  }

}

class ChatMessage {
  final String sender;
  final String message;

  ChatMessage({
    required this.sender,
    required this.message,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'] ?? '',
      message: map['message'] ?? '',
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ChatBubble message: $message");
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black87
          ),
        ),
      ),
    );
  }
}
