import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';

import '../services/session_manager.dart';

class AdminLoginController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void login(BuildContext context, String email, String password) async {
    setLoading(true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is an admin
      if (userCredential.user != null && isUserAdmin(userCredential.user!)) {
        SessionController().userId = userCredential.user!.uid;
        setLoading(false);
        Navigator.pushReplacementNamed(context, RouteName.adminDashboardScreen);
      } else {
        // If not an admin, show error message
        setLoading(false);
        Utils.toastMessage('Invalid admin credentials');
      }
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
