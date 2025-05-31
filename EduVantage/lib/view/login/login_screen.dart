import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:tech_media/view/forgot_password/forgot_password.dart';
import 'package:tech_media/view/signup/sign_up_screen.dart';
import 'package:tech_media/view_model/login/login_controller.dart';

import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/bg.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text('Login',
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: AppFonts.alatsiRegular)),
                    Text("Welcome back!",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            fontFamily: AppFonts.alatsiRegular)),
                    SizedBox(
                      height: 80,
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: height * .06, bottom: height * 0.01),
                        child: Column(
                          children: [
                            InputTextField(
                              myController: emailController,
                              focusNode: emailFocusNode,
                              onFiledSubmitValue: (value) {},
                              keyBoardType: TextInputType.emailAddress,
                              obscureText: false,
                              hint: 'Email',
                              onValidator: (value) {
                                return value.isEmpty ? 'Enter email' : null;
                              },
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.deepPurple,
                              ),
                              isPassword: false,
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            InputTextField(
                              myController: passwordController,
                              focusNode: passwordFocusNode,
                              onFiledSubmitValue: (value) {},
                              keyBoardType: TextInputType.emailAddress,
                              obscureText: true,
                              hint: 'Password',
                              onValidator: (value) {
                                return value.isEmpty ? 'Enter password' : null;
                              },
                              prefixIcon: Icon(Icons.lock,
                                  color: CupertinoColors.systemPink),
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: ForgotPasswordScreen(),
                            withNavBar: false,
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                fontSize: 15,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ChangeNotifierProvider(
                      create: (_) => LoginController(),
                      child: Consumer<LoginController>(
                        builder: (context, provider, child) {
                          return RoundButton(
                              color: Colors.green.withOpacity(0.8),
                              title: 'Log in',
                              loading: provider.loading,
                              onPress: () {
                                if (_formKey.currentState!.validate()) {
                                  provider.login(context, emailController.text,
                                      passwordController.text);
                                }
                              });
                        },
                      ),
                    ),
                    SizedBox(
                      height: height * .03,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: SignUpScreen(),
                            withNavBar: false,
                          );
                        },
                        child: Text.rich(TextSpan(
                            text: "Don't have an account?",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w100),
                            children: [
                              TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800))
                            ])),
                      ),
                    ),
                    SizedBox(height: 110),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AdminLoginScreen(),
                            withNavBar: false,
                          );
                        },
                        icon: Icon(Icons.admin_panel_settings),
                        iconSize: 40,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
