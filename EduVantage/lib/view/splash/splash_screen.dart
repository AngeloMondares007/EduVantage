import 'package:flutter/material.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view_model/services/splash_services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices services = SplashServices();

  @override
  void initState() {
    super.initState();
    services.isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the Scaffold background transparent
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/bg.png', // Replace with your background image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Content (image and text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/sp2.png',
                  width: 500, // Adjust the width as needed
                  height: 450, // Adjust the height as needed
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: Center(
                    child: Text(
                      '', // You can add text here if needed
                      style: TextStyle(
                        fontFamily: AppFonts.sfProDisplayBold,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1d1b00),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
