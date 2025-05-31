import 'package:flutter/material.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tech_media/Firebase_notif_API/Notif_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  tz.initializeTimeZones();
  await Firebase.initializeApp();
  // if(!kDebugMode) {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.playIntegrity,
  //   );
  // } else {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: AndroidProvider.debug,
  //     appleProvider: AppleProvider.debug,
  //   );
  // }

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routes = Routes();
    return MaterialApp(
      title: 'EduVantage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // useMaterial3: false,
        colorScheme:
        ColorScheme.fromSeed(
          seedColor: Colors.blue,
          background: Colors.white,
          error: Colors.red,
          onTertiary: Colors.orange
        ),
        scaffoldBackgroundColor: AppColors.whiteColor,
        appBarTheme: const AppBarTheme(
          color: AppColors.whiteColor,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 22, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor)
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 40, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
            displayMedium: TextStyle(fontSize: 32, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
          displaySmall: TextStyle(fontSize: 15, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.9),
        headlineMedium: TextStyle(fontSize: 24, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
    headlineSmall: TextStyle(fontSize: 20, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
    titleLarge: TextStyle(fontSize: 17, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),
            bodyLarge: TextStyle(fontSize: 17, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),
            bodyMedium: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, height: 1.6),

            titleMedium: TextStyle(fontSize: 17, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),
            titleSmall: TextStyle(fontSize: 25, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),

           bodySmall: TextStyle(fontSize: 15, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, height: 2.26)

        ),
      ),
      initialRoute: RouteName.splashScreen,
      onGenerateRoute: routes.generateRoute,
    );
  }
}

