import 'package:tech_media/res/fonts.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:tech_media/view_model/forgot_password/forgot_password_controller.dart';

import '../../res/color.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      backgroundColor: Colors.white, // Make the background transparent
      appBar: AppBar(
        leading: const BackButton(
          color: AppColors.bgColor,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          background: Opacity(
            opacity: 1, // Adjust the opacity level (0.0 - 1.0)
            child: Image.asset(
              'assets/images/bg.png', // Replace with your image asset path
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/bg.png', // Replace with your image asset path
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6), // Adjust the opacity here
            colorBlendMode: BlendMode.softLight, // Adjust the blend mode if needed
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * .01,),
                    Text('Forgot Password', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: AppFonts.alatsiRegular)),
                    SizedBox(height: height * .01,),
                    Text('Enter your email address\nto recover your password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54, fontFamily: AppFonts.alatsiRegular)) ,
                    SizedBox(height: height * .01,),
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
                                prefixIcon: Icon(Icons.email, color: Colors.deepPurple.withOpacity(0.8),),
                              ),

                              SizedBox(height: height * 0.01,),
                            ],
                          ),
                        )
                    ),

                    const SizedBox(height: 40,),
                    ChangeNotifierProvider(
                      create: (_) => ForgotPasswordController(),
                      child: Consumer<ForgotPasswordController>(
                        builder: (context, provider, child){
                          return RoundButton(
                              color: Colors.green.withOpacity(0.8) ,
                              title: 'Recover',
                              loading: provider.loading,
                              onPress: (){
                                if(_formKey.currentState!.validate()){
                                  provider.forgotPassword(context, emailController.text);
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

