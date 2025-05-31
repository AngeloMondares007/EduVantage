import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/session_manager.dart'; // Import FirebaseDatabase

class LoginController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference databaseRef = FirebaseDatabase.instance.reference(); // DatabaseReference

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context, String email, String password) async {
    setLoading(true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user status from Realtime Database
      DatabaseReference userRef = databaseRef.child('User').child(userCredential.user!.uid);

      // Use onValue to listen for changes and handle the result
      userRef.onValue.listen((event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          // Check if user is disabled
          dynamic userData = snapshot.value; // Store the user data for easy access
          if (userData['status'] == 'disabled') {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, RouteName.loginView, (route) => false);
            setLoading(false);
            Utils.toastMessage('Your account has been disabled. Please contact support for assistance');
            return;
          }

          // Check if the user's email is verified
          if (!userCredential.user!.emailVerified) {
            setLoading(false);
            Utils.toastMessage('Please verify your email address before logging in. Check your inbox and follow the instructions to verify your account');
            return;
          }

          // Check if the user is an admin
          if (isUserAdmin(userCredential.user!)) {
            // If user is admin, prevent login and navigate to admin screen
            setLoading(false);
            Utils.toastMessage('Admins should use the Admin Login screen');
            Navigator.pushNamed(context, RouteName.adminLoginScreen);
          } else {
            // If user is not admin, proceed with regular login flow
            SessionController().userId = userCredential.user!.uid;
            setLoading(false);
            Navigator.pushReplacementNamed(context, RouteName.dashboardScreen);
          }
        } else {
          setLoading(false);
          Utils.toastMessage('User not found in database');
        }
      });
    } catch (e) {
      setLoading(false);
      Utils.toastMessage(e.toString());
    }
  }

  // Function to check if the user is an admin (you should implement your own logic here)
  bool isUserAdmin(User user) {
    // Example: check if the user's email matches the admin email
    return user.email == 'eduvantagea@gmail.com';
  }
}
