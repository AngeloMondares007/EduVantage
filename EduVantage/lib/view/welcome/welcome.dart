import 'package:flutter/material.dart';
import 'package:tech_media/view/login/login_screen.dart';
import 'package:tech_media/view/signup/sign_up_screen.dart';
import 'package:tech_media/res/components/round_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the MediaQuery instance for the current context
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 104, 140, 158),
      body: Stack(
        children: [

          Align(
            alignment: Alignment.center,
            child: Container(
              height: screenHeight / 2,
              width: double.infinity,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'HackathonHub',
                        style: TextStyle(
                          fontFamily: 'Epilogue',
                          fontSize: 45,
                          color: Color(0xffedf2f3),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      'Find your perfect buddy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        color: Color(0xffbedf2f3),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/splash.png',
                      height: 190,
                      width: 190,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RoundButton(
                      title: 'Sign Up',
                      onPress: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (builder) => const SignUpScreen(),
                        ),);
                      }
                  ),

                  RoundButton(
                      title: 'Login',
                      onPress: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (builder) => const LoginScreen(),
                        ),);
                      }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
