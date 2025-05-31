
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/utils.dart';
import 'tasks.dart';

class EditTask extends StatefulWidget {
  final String taskId; // Task ID to edit, pass null for creating a new task
  final DateTime? selectedDay;
  EditTask({required this.taskId, required this.selectedDay});

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final CollectionReference classCollection = FirebaseFirestore.instance
      .collection('Tasks');
  final _formKey = GlobalKey<FormState>();

  String subjectName = '';
  String subjectCode = '';
  DateTime selectedDate = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String description = '';
  String teacher = '';
  String taskType = 'Other'; // Set an initial value for taskType
  Color selectedColor = Colors.purple.shade600;
  TextEditingController subjectNameController = TextEditingController();
  TextEditingController subjectCodeController = TextEditingController();
  TextEditingController teacherController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final List<String> taskTypes = [
    'Assignment',
    'Meeting',
    'Review',
    'Heads-Up',
    'Other'
  ];

  final auth = FirebaseAuth.instance;
  String userUID = "";

  @override
  void initState() {
    super.initState();
    fetchUserUID();
    fetchTaskDetails(widget.taskId);
    setColorForTaskType(taskType); // Initialize color based on default task typ
  }


  Future<void> fetchUserUID() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userUID = currentUser.uid;
      });
    }
  }

  void setColorForTaskType(String type) {
    switch (type) {
      case 'Assignment':
        setState(() {
          selectedColor = Colors.blue;
        });
        break;
      case 'Meeting':
        setState(() {
          selectedColor = Colors.green.shade600;
        });
        break;
      case 'Review':
        setState(() {
          selectedColor = Colors.red.shade800;
        });
        break;
      case 'Heads-Up':
        setState(() {
          selectedColor = Colors.orange.shade600;
        });
        break;
      case 'Other':
        setState(() {
          selectedColor = Colors.purple.shade600;
        });
        break;
    }
  }

  Future<void> fetchTaskDetails(String taskId) async {
    classCollection.doc(taskId).get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          subjectName = data['subjectName'] ?? '';
          subjectNameController.text = data['subjectName'] ?? '';
          subjectCode = data['subjectCode'] ?? '';
          subjectCodeController.text = data['subjectCode'] ?? '';
          selectedDate = (data['date'] != null)
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();
          startTime = DateFormat('h:mm a').parse(data['startTime'] ?? '');
          endTime = DateFormat('h:mm a').parse(data['endTime'] ?? '');
          description = data['description'] ?? '';
          descriptionController.text = data['description'] ?? '';
          teacher = data['teacher'] ?? '';
          teacherController.text = data['teacher'] ?? '';
          taskType = data['taskType'] ?? 'Other';
          selectedColor = data['backgroundColor'] != null
              ? Color(int.parse(data['backgroundColor'], radix: 16))
              : Colors.blue;
        });
      } else {
        print('Task with ID $taskId does not exist.');
      }
    }).catchError((error) {
      print('Error fetching task details: $error');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      keyboardType: TextInputType.datetime,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      helpText: 'Select start time',
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
              primary: Colors.red,
              // Change the primary color
              onPrimary: Colors.white,
              // Change the text color
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
        title: Text(widget.taskId.isEmpty ? "Add New Task" : "Edit Task",
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
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
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(15),
                  decoration: InputDecoration(labelText: 'Task Type'),
                  items: taskTypes.map((String taskType) {
                    return DropdownMenuItem<String>(
                      value: taskType,
                      child: Text(taskType, style: TextStyle(color: Colors.black),),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      taskType = value ?? '';
                      setColorForTaskType(
                          taskType); // Call method to set color based on task type
                    });
                  },
                  value: taskType,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Name'),
                  controller: subjectNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      subjectName = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  controller: subjectCodeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject code';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      subjectCode = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Teacher'),
                  controller: teacherController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a teacher';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      teacher = value;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Date'),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
                  decoration: InputDecoration(labelText: 'Task Description'),
                  controller: descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter task description';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
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
                        if (widget.taskId.isEmpty) {
                          saveTaskData();
                        } else {
                          updateTaskData(widget.taskId);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black87.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        widget.taskId.isEmpty ? "Create Task" : "Update Task",
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

  void saveTaskData() async {
    classCollection.add({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'date': selectedDate,
      'startTime': DateFormat('h:mm a').format(startTime),
      'endTime': DateFormat('h:mm a').format(endTime),
      'description': description,
      'teacher': teacher,
      'taskType': taskType,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
    }).then((_) {
      print('Task added to Firestore');
      final newTask = Task(
        documentID: '',
        date: selectedDate,
        startTime: TimeOfDay.fromDateTime(startTime),
        endTime: TimeOfDay.fromDateTime(endTime),
        subject: subjectName,
        subjectCode: subjectCode,
        teacher: teacher,
        description: description,
        color: selectedColor,
        type: taskType,
      );
      Navigator.pop(context, newTask);
    }).catchError((error) {
      print('Error adding task to Firestore: $error');
    });
  }

  void updateTaskData(String taskId) async {
    classCollection.doc(taskId).update({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'date': selectedDate,
      'startTime': DateFormat('h:mm a').format(startTime),
      'endTime': DateFormat('h:mm a').format(endTime),
      'description': description,
      'teacher': teacher,
      'taskType': taskType,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
    }).then((value) => Navigator.pop(context));
    FirebaseFirestore.instance.collection('ActivityLogs').add({
        "title": "Task Updated",
        "activity": '${await getUserName(userUID)} edited a task "${subjectName}"',
        "timestamp": Timestamp.now(),
    "userId": userUID,
    },);
      print('Task updated in Firestore');
      Utils.toastMessage('Task ${description} edited successfully');
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(
      //       builder: (context) => TaskScreen(userUID: userUID, selectedDay: selectedDate,),
      //     ),);
      // }).catchError((error) {
      //   print('Error updating task in Firestore: $error');
      // });

    }
  }
