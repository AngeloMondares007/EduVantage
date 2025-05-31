import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/signup/signup_controller.dart';

import '../../res/color.dart';
import '../../res/components/Dropdown.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final studentNumberController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userNameController = TextEditingController();

  final emailFocusNode = FocusNode();
  final userNameFocusNode = FocusNode();
  final studentNumberFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  String? _selectedDepartment;
  String? _selectedCourse;

  List<String> _selectedInterests = [];
  final List<String> interests = [
    'Sports',
    'Music',
    'Reading',
    'Art',
    'Science',
    'Technology',
    'Cooking',
    'Gaming',
    'Fashion',
    'Fitness',
    'Literature',
    'Movies',
    'History',
    'Photography',
    'Programming',
  ];

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    // Check if the length of the name is greater than 26 characters
    if (value.length > 26) {
      return 'Name cannot be longer than 26 characters';
    }
    // Check if the first character is a capital letter
    if (!RegExp(r'^[A-Z]').hasMatch(value)) {
      return 'Name must start with a capital letter';
    }
    return null;
  }

  // Function to handle interest selection
  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 3) {
        _selectedInterests.add(interest);
      }
    });
  }

  bool isInterestsValid() {
    return _selectedInterests.isNotEmpty;
  }



  final List<String> departments = [
    'CAS',
    'CEA',
    'CELA',
    'CITE',
    'CMA',
    'CAHS',
    'CCJE'
  ]; // Add your department options here
  final Map<String, List<String>> coursesByDepartment = {
    'CAS': [
      'BS Architecture',
      'BS Civil Engineering',
      'BS Computer Engineering',
      'BS Electronics Engineering',
      'BS Electrical Engineering',
      'BS Mechanical Engineering',
      'BA Communication',
      'BA Political Science',
      'Bachelor of Elementary Education',
      'BSED - Science',
      'BSED - Social Studies',
      'BSED - English',
      'BSED - Math',
      'BS Information Technology',
      'Associate in Computer Technology',
      'BS Accountancy',
      'BS AIS (AcctgTech)',
      'BS Management Accounting',
      'BSBA - Financial Management',
      'BSBA - Marketing Management',
      'BS Tourism Management',
      'BS Hospitality Management',
      'BS Medical Laboratory',
      'BS Nursing',
      'BS Pharmacy',
      'BS Psychology',
      'BS Criminology'
    ],
    'CEA': [
      'BS Architecture',
      'BS Civil Engineering',
      'BS Computer Engineering',
      'BS Electronics Engineering',
      'BS Electrical Engineering',
      'BS Mechanical Engineering'
    ],
    'CELA': [
      'BA Communication',
      'BA Political Science',
      'Bachelor of Elementary Education',
      'BSED - Science',
      'BSED - Social Studies',
      'BSED - English',
      'BSED - Math'
    ],
    'CITE': ['BS Information Technology', 'Associate in Computer Technology'],
    'CMA': [
      'BS Accountancy',
      'BS AIS (AcctgTech)',
      'BS Management Accounting',
      'BSBA - Financial Management',
      'BSBA - Marketing Management',
      'BS Tourism Management',
      'BS Hospitality Management'
    ],
    'CAHS': [
      'BS Medical Laboratory',
      'BS Nursing',
      'BS Pharmacy',
      'BS Psychology'
    ],
    'CCJE': ['BS Criminology'],
  }; // Add courses mapped to each department

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Container(
      color: Colors.white,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          leading: const BackButton(
            color: AppColors.bgColor,
          ),
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
        body: Stack(
          children: [
            Image.asset(
              'assets/images/bg.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ChangeNotifierProvider(
                  create: (_) => SignUpController(),
                  child: Consumer<SignUpController>(
                    builder: (context, provider, child) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: AppFonts.alatsiRegular,
                              ),
                            ),
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Start learning\nSign Up Today!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                                fontFamily: AppFonts.alatsiRegular,
                                height: 0.95,
                              ),
                            ),
                            SizedBox(
                              height: height * .01,
                            ),
                            Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: height * .06, bottom: height * 0.01),
                                child: Column(
                                  children: [
                                    InputTextField(
                                      myController: userNameController,
                                      focusNode: userNameFocusNode,
                                      onFiledSubmitValue: (value) {},
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: false,
                                      hint: 'Username',
                                      onValidator: (value) {
                                        // Validate the username using the validateName function
                                        String? validationResult = SignUpController().validateName(value);
                                        return validationResult;
                                      },
                                      prefixIcon: Icon(Icons.person,
                                          color: CupertinoColors.activeGreen),
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    InputTextField(
                                      myController: emailController,
                                      focusNode: emailFocusNode,
                                      onFiledSubmitValue: (value) {
                                        Utils.fieldFocus(context,
                                            emailFocusNode, passwordFocusNode);
                                      },
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: false,
                                      hint: 'Email',
                                      onValidator: (value) {
                                        return value.isEmpty
                                            ? 'Enter email'
                                            : null;
                                      },
                                      prefixIcon: Icon(Icons.email,
                                          color: Colors.deepPurple),
                                    ),
                                    SizedBox(height: 1),
                                    CustomDropdown<String>(
                                      borderRadius: BorderRadius.circular(15),
                                      value: _selectedDepartment,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDepartment = value;
                                          // Reset course selection when department changes
                                          _selectedCourse = null;
                                        });
                                      },
                                      items: departments,
                                      hintText: 'Department',
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.normal),
                                      prefixIcon: Icon(
                                        Icons.account_balance_rounded,
                                        color: CupertinoColors.systemOrange,
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select a department';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomDropdown<String>(
                                      value: _selectedCourse,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCourse = value;
                                        });
                                      },
                                      items: _selectedDepartment != null
                                          ? coursesByDepartment[
                                              _selectedDepartment!]!
                                          : [],
                                      hintText: 'Course',
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.normal),
                                      prefixIcon: Icon(
                                        Icons.book_rounded,
                                        color: CupertinoColors.activeBlue,
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select a course';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    InputTextField(
                                      myController: studentNumberController,
                                      focusNode: studentNumberFocusNode,
                                      onFiledSubmitValue: (value) {},
                                      keyBoardType: TextInputType.number,
                                      obscureText: false,
                                      hint: 'Student Number',
                                      // inputFormatters: [
                                      //   LengthLimitingTextInputFormatter(14),
                                      //   FilteringTextInputFormatter.digitsOnly,
                                      //   TextInputFormatter.withFunction((oldValue, newValue) {
                                      //     final text = newValue.text;
                                      //     if (text.length == 2 || text.length == 7) {
                                      //       return TextEditingValue(
                                      //         text: '$text-',
                                      //         selection: TextSelection.collapsed(offset: text.length + 1),
                                      //       );
                                      //     }
                                      //     return newValue;
                                      //   }),
                                      // ],
                                      onValidator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Student number cannot be empty';
                                        }
                                        if (!RegExp(r'^\d{2}-\d{4}-\d{6}$').hasMatch(value)) {
                                          return 'Enter a valid student number format';
                                        }
                                        return null;
                                      },
                                      prefixIcon: Icon(Icons.person_pin_rounded,
                                          color: Colors.indigo,),
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
                                        return value.isEmpty
                                            ? 'Enter password'
                                            : null;
                                      },
                                      prefixIcon: Icon(Icons.lock,
                                          color: CupertinoColors.systemPink),
                                      isPassword: true,
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    InputTextField(
                                      myController: confirmPasswordController,
                                      focusNode: confirmPasswordFocusNode,
                                      onFiledSubmitValue: (value) {},
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: true,
                                      hint: 'Confirm Password',
                                      onValidator: (value) {
                                        if (value.isEmpty) {
                                          return 'Enter password again';
                                        } else if (value !=
                                            passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                      prefixIcon: Icon(Icons.lock,
                                          color: CupertinoColors.systemPink),
                                      isPassword: true,
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                            // Interest selection field
                            Container(
                              height: 300,
                              width: 500,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white70, // Background color of the container
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 13),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20), // Adjust the left padding as needed
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          'Interests (Choose up to 3)',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Wrap(
                                      spacing: 8,
                                      children: interests.map((interest) {
                                        bool isSelected = _selectedInterests.contains(interest);
                                        return GestureDetector(
                                          onTap: () => _toggleInterest(interest),
                                          child: Chip(
                                            label: Text(interest, style: TextStyle(fontFamily: AppFonts.alatsiRegular,
                                                color: isSelected ? Colors.white : Colors.black),),
                                            backgroundColor: isSelected ? Colors.teal : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              // side: BorderSide(style: BorderStyle.none),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            RoundButton(
                              color: Colors.green.withOpacity(0.8),
                              title: 'Sign Up',
                              loading: provider.loading,
                              onPress: () {
                                if (_formKey.currentState!.validate()) {
                                  if (passwordController.text == confirmPasswordController.text) {
                                    if (isInterestsValid()) {
                                      // Passwords match and interests are valid, proceed with signup
                                      provider.signup(
                                        context,
                                        userNameController.text,
                                        emailController.text,
                                        passwordController.text,
                                        _selectedDepartment!,
                                        _selectedCourse!,
                                        studentNumberController.text,
                                        _selectedInterests,
                                      );
                                    } else {
                                      // Interests are not selected, display an error message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Please select at least one interest'),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Passwords don't match, display an error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Passwords do not match'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(
                              height: height * .03,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
