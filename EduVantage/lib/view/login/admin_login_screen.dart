import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import '../../res/color.dart';
import '../../view_model/login/admin_login_controller.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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
      appBar: AppBar(
        leading: const BackButton(
          color: AppColors.bgColor,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          background: Opacity(
            opacity: 1,
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
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
                    Text('Admin Login', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: AppFonts.alatsiRegular)),
                    Text("Welcome Admin!",
                        textAlign: TextAlign.left, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54, fontFamily: AppFonts.alatsiRegular)) ,

                    SizedBox(height: 80,),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.only(top: height * .06, bottom: height * 0.01),
                        child: Column(
                          children: [
                            InputTextField(
                              myController: emailController,
                              focusNode: emailFocusNode,
                              onFiledSubmitValue: (value){

                              },
                              keyBoardType: TextInputType.emailAddress,
                              obscureText: false,
                              hint: 'Email',
                              onValidator: (value){
                                return value.isEmpty ? 'Enter email' : null;
                              },
                              prefixIcon: Icon(Icons.email, color: Colors.deepPurple,),
                              isPassword: false,
                            ),

                            SizedBox(height: height * 0.01,),

                            InputTextField(
                              myController: passwordController,
                              focusNode: passwordFocusNode,
                              onFiledSubmitValue: (value){

                              },
                              keyBoardType: TextInputType.emailAddress,
                              obscureText: true,
                              hint: 'Password',
                              onValidator: (value){
                                return value.isEmpty ? 'Enter password' : null;
                              },
                              prefixIcon: Icon(Icons.lock, color: CupertinoColors.systemPink,),
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40,),

                    ChangeNotifierProvider(
                      create: (_) => AdminLoginController(),
                      child: Consumer<AdminLoginController>(
                        builder: (context, provider, child){
                          return RoundButton(
                              color: Colors.green.withOpacity(0.8),

                              title: 'Log in',
                              loading: provider.loading,
                              onPress: (){
                                if(_formKey.currentState!.validate()){
                                  provider.login(context, emailController.text, passwordController.text);
                                }
                              }
                          );
                        },
                      ),
                    ),

                    SizedBox(height: height * .03,),

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
