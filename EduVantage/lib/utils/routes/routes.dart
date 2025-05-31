import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_dashboard_screen.dart';
import 'package:tech_media/view/dashboard/dashboard_screen.dart';
import 'package:tech_media/view/forgot_password/forgot_password.dart';
import 'package:tech_media/view/login/login_screen.dart';
import 'package:tech_media/view/signup/sign_up_screen.dart';
import 'package:tech_media/view/splash/splash_screen.dart';
import 'package:tech_media/view/welcome/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_media/view/login/admin_login_screen.dart';

class Routes {
  final auth = FirebaseAuth.instance;

  Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteName.welcomeView:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case RouteName.loginView:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteName.signUpScreen:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case RouteName.forgotScreen:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteName.adminLoginScreen:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case RouteName.dashboardScreen:
        return MaterialPageRoute(builder: (_) {
          final user = auth.currentUser;
          if (user != null) {
            String userUID = user.uid;
            if (user.email == "eduvantagea@gmail.com") {
              return AdminDashboardScreen();
            } else {
              return DashboardScreen(userUID: userUID);
            }

          } else {
            // Handle the case where the user is not authenticated or UID is unavailable
            return const LoginScreen(); // Replace with an appropriate widget
          }
        });


      case RouteName.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}

// class PlaceholderWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text('User not authenticated'),
//       ),
//     );
//   }
// }
