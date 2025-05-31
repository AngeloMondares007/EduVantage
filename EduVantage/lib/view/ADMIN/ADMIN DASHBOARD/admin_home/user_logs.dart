import 'package:flutter/material.dart';
import 'dart:math';

class UserLogsScreen extends StatelessWidget {
  final String userName;
  final Random _random = Random();

  UserLogsScreen({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5F3FD),
      appBar: AppBar(
        backgroundColor: Color(0xFFE5F3FD),
        elevation: 0,
        title: Text(
          "$userName's Logs",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildCard(
            title: "Tasks",
            icon: Icons.check_circle,
            color: Colors.green,
            logs: [
              _buildLog("Completed task: ${_getRandomTask()}"),
              _buildLog("Completed task: ${_getRandomTask()}"),
              _buildLog("Completed task: ${_getRandomTask()}"),
            ],
          ),
          _buildCard(
            title: "Class",
            icon: Icons.school,
            color: Colors.blue,
            logs: [
              _buildLog("Class: ${_getRandomClass()}"),
              _buildLog("Class: ${_getRandomClass()}"),
              _buildLog("Class: ${_getRandomClass()}"),
            ],
          ),
          _buildCard(
            title: "Notes",
            icon: Icons.edit,
            color: Colors.orange,
            logs: [
              _buildLog("Created note: ${_getRandomNote()}"),
              _buildLog("Created note: ${_getRandomNote()}"),
              _buildLog("Created note: ${_getRandomNote()}"),
            ],
          ),
          _buildCard(
            title: "Flashcards",
            icon: Icons.flash_on,
            color: Colors.purple,
            logs: [
              _buildLog("Created flashcards: ${_getRandomFlashcard()}"),
              _buildLog("Created flashcards: ${_getRandomFlashcard()}"),
              _buildLog("Created flashcards: ${_getRandomFlashcard()}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> logs,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: logs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLog(String logText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          logText,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          "Timestamp: ${_getRandomTimestamp()}",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 8),
        Divider(color: Colors.grey[300], height: 1),
        SizedBox(height: 8),
      ],
    );
  }

  String _getRandomTask() {
    List<String> tasks = [
      "Review",
      "Heads-Up",
      "Test",
      "Assignment",
      "Meeting",
    ];
    return tasks[_random.nextInt(tasks.length)];
  }

  String _getRandomClass() {
    List<String> classes = [
      "Mathematics",
      "Science",
      "History",
      "English",
      "Physics",
    ];
    return classes[_random.nextInt(classes.length)];
  }

  String _getRandomNote() {
    List<String> notes = [
      "My Notes",
      "Reminders",
      "Science",
      "API",
      "Kasaysayan",
    ];
    return notes[_random.nextInt(notes.length)];
  }

  String _getRandomFlashcard() {
    List<String> flashcards = [
      "Math",
      "History",
      "Random",
      "Trivia",
      "Flags",
    ];
    return flashcards[_random.nextInt(flashcards.length)];
  }

  String _getRandomTimestamp() {
    DateTime now = DateTime.now();
    String timestamp = "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)} "
        "${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year}";
    return timestamp;
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

void main() => runApp(MaterialApp(
  home: UserLogsScreen(userName: "John Doe"),
));
