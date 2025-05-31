import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

class SignUpController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<UserModel?> createUserModelFromDatabase(String uid) async {
    try {
      DatabaseEvent event = await ref.child(uid).once();
      if (event.snapshot.exists) {
        Map<String, dynamic>? userMap =
        event.snapshot.value as Map<String, dynamic>?;
        if (userMap != null) {
          return UserModel.fromMap(userMap);
        }
      }
      return null; // Return null if the user doesn't exist in the database
    } catch (error) {
      Utils.toastMessage(error.toString());
      return null;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    // Check if the length of the name is greater than 26 characters
    if (value.length > 30) {
      return 'Name cannot be longer than 30 characters';
    }
    // Check if the first character is a capital letter
    if (!RegExp(r'^[A-Z]').hasMatch(value)) {
      return 'Name must start with a capital letter';
    }
    return null;
  }

  void signup(BuildContext context, String username, String email,
      String password, String selectedDepartment, String selectedCourse, String studentNumber, List<String> _selectedInterests) async {
    setLoading(true);

    try {
      // Validate email format
      if (!(email.endsWith('@gmail.com') || email.endsWith('@phinmaed.com'))) {
        setLoading(false);
        Utils.toastMessage('Please use an email address ending with @gmail.com or @phinmaed.com');
        return;
      }

      // Validate password strength
      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$').hasMatch(password)) {
        setLoading(false);
        Utils.toastMessage('Password should be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character');
        return;
      }

      // Additional password strength checks can be added here

      auth.createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        // Send email verification
        value.user!.sendEmailVerification().then((_) {
          Utils.toastMessage('A verification email has been sent to your email address. Please check your inbox and follow the instructions to verify your account');
        }).catchError((error) {
          Utils.toastMessage('Failed to send verification email. Please contact support for assistance');
        });

        SessionController().userId = value.user!.uid.toString();

        ref.child(value.user!.uid.toString()).set({
          'uid': value.user!.uid.toString(),
          'email': value.user!.email.toString(),
          'onlineStatus': 'true',
          'phone': '',
          'userName': username,
          'profile': '',
          'department': selectedDepartment,
          'course': selectedCourse,
          'studentNumber': studentNumber, // Save student number to the database
          'interests': _selectedInterests, // Save user's interests to the database
        }).then((value) {
          setLoading(false);
          Navigator.pushReplacementNamed(context, RouteName.loginView);
        }).onError((error, stackTrace) {
          setLoading(false);
          Utils.toastMessage(error.toString());
        });
      }).onError((error, stackTrace) {
        setLoading(false);
        Utils.toastMessage(error.toString());
      });
    } catch (e) {
      setLoading(false);
      Utils.toastMessage(e.toString());
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String onlineStatus;
  final String phone;
  final String userName;
  final String profile;
  final String department;
  final String course;
  final String studentNumber; // Add student number field
  final List<String> interests; // Add interests field

  UserModel({
    required this.uid,
    required this.email,
    required this.onlineStatus,
    required this.phone,
    required this.userName,
    required this.profile,
    required this.department,
    required this.course,
    required this.studentNumber, // Initialize student number in the constructor
    required this.interests, // Initialize interests in the constructor
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      onlineStatus: map['onlineStatus'],
      phone: map['phone'],
      userName: map['userName'],
      profile: map['profile'],
      department: map['department'],
      course: map['course'],
      studentNumber: map['studentNumber'], // Assign student number from the map
      interests: List<String>.from(map['interests'] ?? []), // Assign interests from the map
    );
  }
}


