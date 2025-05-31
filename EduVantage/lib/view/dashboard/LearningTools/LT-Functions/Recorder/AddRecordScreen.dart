import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:googleapis_auth/auth_io.dart' as auth_io;
import 'package:tech_media/res/fonts.dart';

import '../../../../../utils/utils.dart';

class AddRecordScreen extends StatefulWidget {
  @override
  _AddRecordScreenState createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  bool isRecording = false;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? path;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive']);

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    path = '/storage/emulated/0/Download/temp.wav'; // Update path as needed
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Record Audio",
          style: TextStyle(
            color: Colors.black26,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    isRecording ? Icons.mic : Icons.mic_none,
                    size: 100,
                    color: isRecording ? Colors.red : Colors.green,
                  ),
                  SizedBox(height: 20),
                  Text(
                    isRecording ? 'Recording...' : 'Click the button below to start recording',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: _startStopRecording,
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 40,
                    color: isRecording ? Colors.red : Colors.green,
                  ),
                  style: TextButton.styleFrom(
                    shape: CircleBorder(),
                  ),
                ),
                if (!isRecording)
                  TextButton.icon(
                    onPressed: () {
                      _promptFileName(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      Icons.save,
                      color: Color(0xFFe5f3fd),
                    ),
                    label: Text(
                      "Save",
                      style: TextStyle(
                        fontFamily: AppFonts.alatsiRegular,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startStopRecording() async {
    if (isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _requestPermission()) {
      try {
        await _recorder.startRecorder(
          toFile: path!,
          codec: Codec.pcm16WAV,
        );

        setState(() {
          isRecording = true;
        });
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
  }

  Future<bool> _requestPermission() async {
    if (await Permission.microphone.request().isGranted &&
        await Permission.storage.request().isGranted) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please grant microphone and storage permissions.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }

  Future<void> _promptFileName(BuildContext context) async {
    TextEditingController fileNameController = TextEditingController();
    // Show dialog to enter file name
    String? fileName = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Enter File Name', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.bold),),
        content: TextField(
          cursorColor: Colors.black87,
          style: TextStyle(fontWeight: FontWeight.normal),
          controller: fileNameController,
          decoration: InputDecoration(
            hintText: 'File name',
            hintStyle: TextStyle(fontWeight: FontWeight.normal),
            // Set the color of the underline here
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey), // Change this to the color you want
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black87, width: 2), // Change this to the color you want
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
          ),
          TextButton(
            onPressed: () {
              String enteredFileName = fileNameController.text.trim();
              if (enteredFileName.isNotEmpty && !enteredFileName.trim().isEmpty) {
                Navigator.pop(context, enteredFileName);
                Utils.toastMessage('Recording $enteredFileName saved');// Pass the entered file name back
                Navigator.pop(context, enteredFileName);
              } else {
                Utils.toastMessage('Please enter a file name');
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),),
          ),
        ],
      ),
    );
    // Save the recording with the entered file name
    if (fileName != null && fileName.isNotEmpty) {
      await _saveRecording(fileName);
    }
  }

  Future<void> _saveRecording(String? fileName) async {
    try {
      if (await Permission.storage.request().isGranted) {
        if (path != null) {
          // Sign in with Google
          final google_sign_in.GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
          final GoogleSignInAuthentication? authentication = await googleSignInAccount?.authentication;
          if (authentication != null) {
            try {
              final googleSignIn = GoogleSignIn();

              final googleSignInAccount = await googleSignIn.signInSilently();

              if (googleSignInAccount != null) {
                final googleSignInAuthentication = await googleSignInAccount.authentication;

                final accessToken = auth.AccessToken('Bearer', googleSignInAuthentication.accessToken!, DateTime.now().add(Duration(hours: 1)).toUtc());

                final credentials = auth.AccessCredentials(
                  accessToken,
                  null,
                  [],
                  idToken: googleSignInAuthentication.idToken,
                );

                final authClient = auth_io.authenticatedClient(
                  http.Client(),
                  credentials,
                );
                final driveApi = drive.DriveApi(authClient);

                // Check if the folder exists
                String? folderId = await _getFolderId(driveApi, 'EduVantageRecordings');

                if (folderId == null) {
                  // Create the folder if it doesn't exist
                  final drive.File folder = drive.File()
                    ..name = 'EduVantageRecordings'
                    ..mimeType = 'application/vnd.google-apps.folder';
                  final createdFolder = await driveApi.files.create(folder);
                  folderId = createdFolder.id ?? ''; // Use an empty string as a fallback value
                }

                // Upload the file inside the existing or newly created folder
                final fileBytes = File(path!).readAsBytesSync();
                final media = drive.Media(
                  Stream.fromIterable([fileBytes]),
                  fileBytes.length,
                );

                final fileMetadata = drive.File()
                  ..name = '$fileName.aac'
                  ..parents = [folderId];

                final uploadedFile = await driveApi.files.create(
                  fileMetadata,
                  uploadMedia: media,
                );

                log('File uploaded: ${uploadedFile.name}');
                FirebaseFirestore.instance.collection('ActivityLogs').add({
                  "title": "Recording Added",
                  "activity": '${await getUserName(FirebaseAuth.instance.currentUser!.uid)} added a recording "${fileName}"',
                  "timestamp": Timestamp.now(),
                  "userId": FirebaseAuth.instance.currentUser!.uid,
                });
              } else {
                print('Google sign-in account is null');
              }
            } catch (e) {
              // Handle upload error
              print('Error uploading file: $e');
            }
          } else {
            print('Authentication is null');
          }
        } else {
          print('Error: Recording path is null');
        }
      } else {
        print('Permission not granted');
      }
    } catch (e) {
      print('Error saving recording: $e');
    }
  }

  Future<String?> _getFolderId(drive.DriveApi driveApi, String folderName) async {
    try {
      final response = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.folder' and name='$folderName'",
      );

      if (response.files != null && response.files!.isNotEmpty) {
        return response.files!.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting folder ID: $e');
      return null;
    }
  }

  Future<String> getUserName(String userUID) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('User').doc(userUID).get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        String userName = userData['userName'] ?? ''; // Assuming 'userName' is the key for the user's name
        return userName;
      } else {
        return ''; // Return an empty string if user data is not found
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return ''; // Return an empty string in case of an error
    }
  }
}
