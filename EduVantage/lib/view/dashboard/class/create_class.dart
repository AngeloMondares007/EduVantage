import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Firebase_notif_API/Notif_service.dart';
import '../../../utils/utils.dart';


class CreateNewClassScreen extends StatefulWidget {
  @override
  _CreateNewClassScreenState createState() => _CreateNewClassScreenState();
}

NotificationService notificationService = NotificationService();

class _CreateNewClassScreenState extends State<CreateNewClassScreen> {
  final CollectionReference classCollection =
  FirebaseFirestore.instance.collection('Class');
  final _formKey = GlobalKey<FormState>();

  String subjectName = '';
  String subjectCode = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String room = '';
  String teacher = '';
  Color selectedColor = Colors.blue;

  final auth = FirebaseAuth.instance;
  String userUID = "";

  @override
  void initState() {
    super.initState();
    fetchUserUID();
  }

  Future<void> fetchUserUID() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userUID = currentUser.uid;
      });
    }
  }

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      helpText:'Select start time',
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
      // Customize the appearance of the time picker
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Modify the color and shape of the time picker
            colorScheme: ColorScheme.light(
                primary: Colors.blue, // Change the primary color
                onPrimary: Colors.white, // Change the text color
                secondary: Colors.blue,
                onSecondary: Colors.white
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Change the button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        startTime = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      helpText: 'Select end time', // Customized help text
      context: context,
      initialTime: TimeOfDay.fromDateTime(endTime),
      // Customize the appearance of the time picker
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Modify the color and shape of the time picker
            colorScheme: ColorScheme.dark(
              primary: Colors.red, // Change the primary color
              onPrimary: Colors.white, // Change the text color
              secondary: Colors.red,
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Change the button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        endTime = DateTime(
          endTime.year,
          endTime.month,
          endTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Class", style: TextStyle(color: Colors.black87)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Name'),
                  onChanged: (value) {
                    setState(() {
                      subjectName = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a subject name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  onChanged: (value) {
                    setState(() {
                      subjectCode = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a subject code';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectStartTime(context);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Start Time'),
                          child: Text(
                            DateFormat('h:mm a').format(startTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectEndTime(context);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'End Time'),
                          child: Text(
                            DateFormat('h:mm a').format(endTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Room'),
                  onChanged: (value) {
                    setState(() {
                      room = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a room';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Teacher'),
                  onChanged: (value) {
                    setState(() {
                      teacher = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a teacher';
                    }
                    return null;
                  },
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            'Pick a color',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: MaterialColorPicker(
                            selectedColor: selectedColor,
                            onColorChange: (Color color) {
                              changeColor(color);
                            },
                            onBack: () {},
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Perform any additional actions if needed
                              },
                              child: Text(
                                'Select',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFonts.alatsiRegular,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "Choose Panel Color",
                    style: TextStyle(
                      fontFamily: AppFonts.alatsiRegular,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selectedColor,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        saveClassData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: Colors.black87.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        "Create Class",
                        style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveClassData() async {
    classCollection
        .add({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'room': room,
      'teacher': teacher,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
    })
        .then((documentReference) {
      print('Class added to Firestore');

      scheduleNotification(documentReference.id, startTime);

    })
        .catchError((error) {
      print('Error adding class to Firestore: $error');
    });
    FirebaseFirestore.instance.collection('ActivityLogs').add({
      "title": "Class Added",
      "activity": '${await getUserName(userUID)} added a class "${subjectName}"',
      "timestamp": Timestamp.now(),
      "userId": userUID,
    }).then((value) => Navigator.pop(context));
    Utils.toastMessage('Class ${subjectName} created successfully');
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

  void scheduleNotification(String classId, DateTime classStartTime) async {
    print('Scheduling notification for class $classId');
    final timeDifference = classStartTime.difference(DateTime.now());

    await notificationService.scheduleNotification(
      id: classId.hashCode,
      title: 'Class Reminder',
      body: 'Your class ($subjectName) is about to start!',
      scheduledNotificationDateTime: DateTime.now().add(timeDifference),
    );
    print('Notification scheduled successfully');
  }
}