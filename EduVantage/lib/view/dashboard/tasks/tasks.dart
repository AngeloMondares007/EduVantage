
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_media/view/dashboard/tasks/create_task.dart';
import 'package:tech_media/view/dashboard/tasks/edit_task.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../res/fonts.dart';
import '../../../utils/utils.dart';

class TaskScreen extends StatefulWidget {
  final String userUID;
  final DateTime? selectedDay;
  final bool? loadData;
  TaskScreen({required this.userUID, this.selectedDay, this.loadData});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasks = []; // List of tasks

  void togglePinTask(Task task) {
    setState(() {
      task.pinned = !task.pinned; // Toggle the pinned status
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    _loadTaskData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
      _loadTaskData();
    }
  }

  Future<void> togglePinTaskInFirestore(String taskId, bool pinned) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).update({
        'pinned': pinned,
      });
    } catch (e) {
      print("Error updating pinned status in Firestore: $e");
    }
  }

  Future<void> deleteTaskFromFirestore(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).delete();
    } catch (e) {
      print("Error deleting task from Firestore: $e");
    }
  }

  Future<void> toggleDoneStatusInFirestore(String taskId, bool isDone) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).update({
        'isDone': isDone,
        'completionDate': DateTime.now()
      });
    } catch (e) {
      print("Error updating task status in Firestore: $e");
    }
  }

  // Function to load task data from Firestore
  Future<void> _loadTaskData() async {
    try {
      final taskSnapshot = await FirebaseFirestore.instance.collection('Tasks')
          .where('userUID', isEqualTo: widget.userUID) // Filter by userUID
          .get();

      final taskList = taskSnapshot.docs.map((document) {
        final data = document.data();
        return Task(
          documentID: document.id, // Added documentID
          date: (data['date'] as Timestamp).toDate(),
          startTime: TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['startTime'])),
          endTime: TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['endTime'])),
          subject: data['subjectName'] ?? '',
          subjectCode: data['subjectCode'] ?? '',
          teacher: data['teacher'] ?? '',
          description: data['description'] ?? '',
          color: Color(int.parse(data['backgroundColor'], radix: 16)),
          type: data['taskType'] ?? '',
          pinned: data['pinned'] ?? false, // Provide default value if null
          isDone: data['isDone'] ?? false, // Provide default value if null
        );
      }).toList();

      setState(() {
        _tasks = taskList;
      });
    } catch (e) {
      print("Error loading task data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        title: Text('Tasks', style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: AppFonts.alatsiRegular,
        ),),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFe5f3fd),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjust padding as needed
            child: ElevatedButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjust button padding
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Adjust the border radius as needed
                    side: BorderSide(color: Colors.transparent), // Border color
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.indigo), // Text color
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Text color
              ),
              onPressed: () {
                // Navigate to the task creation screen without the navigation bar
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: CreateTask(userUID: widget.userUID),
                  withNavBar: false,
                ).then((newTask) {
                  if (newTask != null) {
                    setState(() {
                      _tasks.add(newTask);
                    });
                  }
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 12), // Icon before the text
                  SizedBox(width: 4), // Space between icon and text
                  Text('Add Task', style: TextStyle(fontSize: 12, fontFamily: AppFonts.alatsiRegular, )), // Button text with smaller font size
                ],
              ),
            ),
          )



        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            pageJumpingEnabled: true,
           startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: CalendarStyle(
              // weekNumberTextStyle: TextStyle(color: ),
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            daysOfWeekHeight: 20,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _tasks
                  .where((task) =>
              task.date.year == day.year &&
                  task.date.month == day.month &&
                  task.date.day == day.day)
                  .map((task) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
              ))
                  .toList();
            },
          ),
          SizedBox(height: 16.0), // Add spacing between calendar and task panels
          Expanded(
            child: _buildTaskPanels(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskPanels() {
    // Filter tasks that match the selected date
    final filteredTasks = _tasks.where((task) =>
    task.date.year == _selectedDay?.year &&
        task.date.month == _selectedDay?.month &&
        task.date.day == _selectedDay?.day).toList();


    // Sort the filteredTasks based on their startTime
    filteredTasks.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));


    return RefreshIndicator(
      onRefresh: _loadTaskData, // Refresh when dragged down
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _buildTaskPanel(task);
        },
      ),
    );
  }

  Widget _buildTaskPanel(Task task) {
    // Define the background color for the task panel.
    Color panelBackgroundColor = task.color;

    // Define the text color for the task title and subtitle.
    Color titleTextColor = Colors.white; // Change this color to your desired text color

    String timeRange = '${task.startTime.format(context)} - ${task.endTime.format(context)}';

    // Check if the task is pinned and change the panel appearance accordingly
    bool isPinned = task.pinned;

    void handlePinTask(Task task) {
      togglePinTaskInFirestore(task.documentID, !task.pinned);
      togglePinTask(task);
    }

    void handleEditTask(Task task) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: Scaffold(body: EditTask(taskId: task.documentID, selectedDay: _selectedDay)),
        withNavBar: false,
      );
    }

    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => EditTask(taskId: task.documentID, selectedDay: _selectedDay),
    //     )
    // );

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


    void markAsDone(Task task) async {
      setState(() {
        task.isDone = true;
        Utils.toastMessage('You marked ${task.type} as done');
      });

      toggleDoneStatusInFirestore(task.documentID, true);

      // Assuming 'task' has 'userUID' property for the user who created the task
      String userName = await getUserName(widget.userUID);

      FirebaseFirestore.instance.collection('ActivityLogs').add({
        "title": "Task Marked as Done",
        "activity": '$userName marked task "${task.type}" as done',
        "timestamp": Timestamp.now(),
        "userId": widget.userUID,
      }).then((_) {
        print('Activity log added for marking task as done');
      }).catchError((error) {
        print('Error adding activity log: $error');
      });
    }


    void handleDeleteTask(Task task) {
      // Implement the logic to delete the task
      deleteTaskFromFirestore(task.documentID); // Delete the task from Firestore
      setState(() {
        _tasks.remove(task); // Remove the task from the local list
      });
    }

    void _showDeleteConfirmationDialog(Task task) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            title: Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
            content: Text('Are you sure you want to delete this task?', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14 ),),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.red, fontSize: 14)),
              ),
              TextButton(
                onPressed: () {
                  handleDeleteTask(task);
                  Navigator.of(context).pop(); // Close the dialog
                  Utils.toastMessage('Task deleted successfully');
                },
                child: Text('Delete', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular, fontSize: 14)),
              ),
            ],
          );
        },
      );
    }

    // Calculate color luminance to determine text color
    double luminance = panelBackgroundColor.computeLuminance();
    Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
    Color borderColor = luminance > 0.5 ? Colors.black : Colors.yellow.shade800;

    bool containsUrl = task.description.contains('http') || task.description.contains('www');

    void _showTaskDetailsDialog(Task task) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.category, size: 16),
                      SizedBox(width: 8),
                      Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${task.type ?? 'N/A'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.book, size: 16),
                      SizedBox(width: 8),
                      Text('Subject:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${task.subject ?? 'No Subject'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.book_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Subject Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${task.subjectCode ?? 'No Code'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person, size: 16),
                      SizedBox(width: 8),
                      Text('Teacher:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${task.teacher ?? 'No Teacher'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_month, size: 16),
                      SizedBox(width: 8),
                      Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${DateFormat('MMM dd, yyyy').format(task.date ?? DateTime.now())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.alarm, size: 16),
                      SizedBox(width: 8),
                      Text('Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${task.startTime.format(context) ?? 'N/A'} - ${task.endTime.format(context) ?? 'N/A'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description, size: 16),
                      SizedBox(width: 4),
                      Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (task.description.contains('http') || task.description.contains('www')) {
                              _launchURL(task.description);
                            }
                          },
                          child: Text(
                            '${task.description ?? 'No Description'}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: task.description.contains('http') || task.description.contains('www')
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
                child: Text('Close', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular, fontSize: 14),),
              ),
            ],
          );

        },
      );
    }
    // log(task.isDone.toString());
    return GestureDetector(
      onTap: () {
        _showTaskDetailsDialog(task);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: panelBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: task.pinned ? Border.all(color: borderColor, width: 3) : null,
        ),
        child: Stack(
          children: [
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row (
                    children: [
                        Text(
                          '${task.type}',
                          style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        if (task.isDone)
                        Icon(Icons.check_circle, color: textColor, size: 20),
                    ],
                  ),
                  Text(
                    '${task.subject}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w100, fontSize: 18, height: 1.5),
                  ),
                  Text(
                    '${task.subjectCode}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w100, fontSize: 17, height: 1),
                  ),
                  Text(
                    '${task.teacher}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w100, fontSize: 16, height: 1),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month, // Calendar icon
                        size: 15,
                        color: textColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(task.date)}',
                        style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w100, height: 1),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.alarm, // Clock icon
                        size: 15,
                        color: textColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '$timeRange', // Display the concatenated time range
                        style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w100, height: 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${task.description}',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w100, fontSize: 18, height: 1),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                onSelected: (choice) {
                  if (choice == 'Pin') {
                    handlePinTask(task);
                  } else if (choice == 'Unpin') {
                    handlePinTask(task);
                  } else if (choice == 'Edit') {
                    handleEditTask(task);
                  } else if (choice == 'Delete') {
                    _showDeleteConfirmationDialog(task);
                  } else if (choice == 'Mark as Done') {
                    markAsDone(task);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    task.pinned ? 'Unpin' : 'Pin', // Display "Unpin" if pinned, "Pin" if not pinned
                  if (!task.isDone)"Mark as Done",
                    'Edit',
                    'Delete'
                  ].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice, style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular),)
                    );
                  }).toList();
                },
                icon: Icon(Icons.more_vert, color: textColor), // Icon for the kebab menu
              ),
            ),
          ],
        ),
      ),
    );
  }
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


class Task {
  final String documentID; // Added documentID
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String subject;
  final String subjectCode;
  final String teacher;
  final String description;
  final Color color;
  final String type;
  bool pinned; // New field to track if the task is pinned
  bool isDone; // New field to track if the task is done

  Task({
    required this.documentID, // Added documentID
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.subjectCode,
    required this.teacher,
    required this.description,
    required this.color,
    required this.type,
    this.pinned = false, // Default is unpinned
    this.isDone = false,
  });
}
