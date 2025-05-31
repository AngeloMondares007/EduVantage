import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/res/fonts.dart';

class EditDepartmentCourseScreen extends StatefulWidget {
  final String initialDepartment;
  final String initialCourse;
  final String userId; // Add userId parameter here

  const EditDepartmentCourseScreen({
    Key? key,
    required this.initialDepartment,
    required this.initialCourse,
    required this.userId, // Initialize userId here
  }) : super(key: key);

  @override
  _EditDepartmentCourseScreenState createState() =>
      _EditDepartmentCourseScreenState();
}

class _EditDepartmentCourseScreenState
    extends State<EditDepartmentCourseScreen> {
  late String _selectedDepartment;
  late String _selectedCourse;
  final List<String> departments = [
    'CAS',
    'CEA',
    'CELA',
    'CITE',
    'CMA',
    'CAHS',
    'CCJE'
  ]; // Add your department options here
  final Map<String, List<String>> coursesByDepartment = {
    'CAS': [
      'BS Architecture', 'BS Civil Engineering', 'BS Computer Engineering',
      'BS Electronics Engineering', 'BS Electrical Engineering',
      'BS Mechanical Engineering', 'BA Communication', 'BA Political Science', 'Bachelor of Elementary Education',
      'BSED - Science', 'BSED - Social Studies',
      'BSED - English', 'BSED - Math', 'BS Information Technology', 'Associate in Computer Technology', 'BS Accountancy', 'BS AIS (AcctgTech)', 'BS Management Accounting',
      'BSBA - Financial Management', 'BSBA - Marketing Management',
      'BS Tourism Management', 'BS Hospitality Management', 'BS Medical Laboratory', 'BS Nursing', 'BS Pharmacy', 'BS Psychology', 'BS Criminology'
    ],

    'CEA': [
      'BS Architecture',
      'BS Civil Engineering',
      'BS Computer Engineering',
      'BS Electronics Engineering',
      'BS Electrical Engineering',
      'BS Mechanical Engineering'
    ],

    'CELA': [
      'BA Communication',
      'BA Political Science',
      'Bachelor of Elementary Education',
      'BSED - Science',
      'BSED - Social Studies',
      'BSED - English',
      'BSED - Math'
    ],

    'CITE': ['BS Information Technology', 'Associate in Computer Technology'],

    'CMA': [
      'BS Accountancy',
      'BS AIS (AcctgTech)',
      'BS Management Accounting',
      'BSBA - Financial Management',
      'BSBA - Marketing Management',
      'BS Tourism Management',
      'BS Hospitality Management'
    ],

    'CAHS': [
      'BS Medical Laboratory',
      'BS Nursing',
      'BS Pharmacy',
      'BS Psychology'
    ],

    'CCJE': ['BS Criminology'],
  }; // Add courses mapped to each department

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.initialDepartment;
    _selectedCourse = widget.initialCourse.isNotEmpty
        ? widget.initialCourse
        : coursesByDepartment[_selectedDepartment]!.first;
  }

  void _saveChangesToDatabase() {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('User') // Change this path to your desired location
        .child(widget.userId); // Use widget.userId

    ref.update({
      'department': _selectedDepartment,
      'course': _selectedCourse,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Department and Course updated successfully'),
        ),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update Department and Course'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Text('Edit Department and Course', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department',
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              borderRadius: BorderRadius.circular(15),
              style: TextStyle(fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontFamily: AppFonts.alatsiRegular, fontSize: 17),
              dropdownColor: Colors.white,
              elevation: 0,
              value: _selectedDepartment,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue!;
                  // Reset course selection when department changes
                  _selectedCourse = coursesByDepartment[_selectedDepartment]!.first;
                });
              },
              items: departments.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Course',
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              borderRadius: BorderRadius.circular(15),
              style: TextStyle(fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontFamily: AppFonts.alatsiRegular, fontSize: 17),
              dropdownColor: Colors.white,
              elevation: 0,
              value: _selectedCourse,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCourse = newValue!;
                });
              },
              items: _selectedDepartment.isNotEmpty
                  ? coursesByDepartment[_selectedDepartment]!.map<
                  DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()
                  : [],
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _saveChangesToDatabase,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // text color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // button border radius
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 16, // text size
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
