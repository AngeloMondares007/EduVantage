import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';


import '../../admin_home/user_activities.dart';
import '../../admin_profile/admin_edit.dart';

class AdminUserDetails extends StatelessWidget {
  final String userId;

  const AdminUserDetails({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref =
    FirebaseDatabase.instance.reference().child('User').child(userId);


    // Function to validate name format
    String? validateName(String? value) {
      if (value == null || value.isEmpty) {
        return 'Name cannot be empty';
      }
      // Check if the length of the name is greater than 26 characters
      if (value.length > 30) {
        return 'Name cannot be longer than 30 characters';
      }
      // Check if the first character is a capital letter
      if (!RegExp(r'^[A-Z]').hasMatch(value)) {
        return 'Name must start with a capital letter';
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            content: CachedNetworkImage(
                              imageUrl: map['profile'] ?? '',
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.no_photography_rounded, color: Colors.red,),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: CachedNetworkImageProvider(map['profile'] ?? ''),
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    map['userName'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    onTap: () {
                      // Handle Username tap
                      // For example, show a dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController usernameController =
                          TextEditingController(text: map['userName'] ?? '');
                          return AlertDialog(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            title: Text(
                              'Edit Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                  cursorColor: Colors.black87,
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter username',
                                    hintStyle: TextStyle(fontWeight: FontWeight.normal),
                                    // Set the color of the underline here
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey), // Change this to the color you want
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black87, width: 2), // Change this to the color you want
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  String? validationResult = validateName(usernameController.text.trim());
                                  if (validationResult != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(validationResult),
                                      ),
                                    );
                                  } else {
                                    // Proceed with saving logic
                                    String newUsername = usernameController.text.trim();
                                    ref.update({'userName': newUsername}).then((_) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Username updated successfully'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update username'),
                                        ),
                                      );
                                    });
                                  }
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.person_alt,
                            color: CupertinoColors.activeBlue),
                        SizedBox(width: 10),
                        Text('Username:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(map['userName'] ?? '',
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    onTap: () {
                      // Navigate to EditDepartmentCourseScreen using PersistentNavBarNavigator
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: EditDepartmentCourseScreen(
                          initialDepartment: map['department'] ?? '',
                          initialCourse: map['course'] ?? '',
                          userId: userId, // Pass the userId here
                        ),
                      ).then((result) {
                        if (result != null) {
                          // Handle the result here (new department and course)
                          String newDepartment = result['department'];
                          String newCourse = result['course'];
                          // Implement logic to update database with new values
                        }
                      });
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_rounded,
                            color: CupertinoColors.destructiveRed),
                        SizedBox(width: 10),
                        Text('Department:',
                            style: TextStyle(
                              fontFamily: AppFonts.alatsiRegular,
                              fontSize: 14,
                              color: Colors.black54,
                            )),
                      ],
                    ),
                    title: Text(map['department'] ?? '',
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    onTap: () {
                      // Navigate to EditDepartmentCourseScreen using PersistentNavBarNavigator
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: EditDepartmentCourseScreen(
                          initialDepartment: map['department'] ?? '',
                          initialCourse: map['course'] ?? '',
                          userId: userId, // Pass the userId here
                        ),
                      ).then((result) {
                        if (result != null) {
                          // Handle the result here (new department and course)
                          String newDepartment = result['department'];
                          String newCourse = result['course'];
                          // Implement logic to update database with new values
                        }
                      });
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.book_rounded,
                            color: CupertinoColors.activeGreen),
                        SizedBox(width: 10),
                        Text('Course:',
                            style: TextStyle(
                              fontFamily: AppFonts.alatsiRegular,
                              fontSize: 14,
                              color: Colors.black54,
                            )),
                      ],
                    ),
                    title: Text(map['course'] ?? '',
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController studentNumberController =
                          TextEditingController(text: map['studentNumber'] ?? '');
                          return AlertDialog(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: Text(
                              'Edit Student Number',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                  cursorColor: Colors.black87,
                                  controller: studentNumberController,
                                  keyboardType: TextInputType.number,
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  //   LengthLimitingTextInputFormatter(12),
                                  //   // Custom input formatter to enforce specific format
                                  //   TextInputFormatter.withFunction((oldValue, newValue) {
                                  //     final newString = newValue.text;
                                  //     if (newString.length <= 10) {
                                  //       // Format: XX-XXXX-XXXXXX
                                  //       if (newString.length == 2 || newString.length == 7) {
                                  //         return TextEditingValue(
                                  //           text: '$newString-',
                                  //           selection: TextSelection.collapsed(offset: newString.length + 1),
                                  //         );
                                  //       }
                                  //     }
                                  //     return newValue.copyWith(
                                  //       text: newString.substring(0, 12),
                                  //       selection: TextSelection.collapsed(offset: newString.length),
                                  //     );
                                  //   }),
                                  // ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter student number',
                                    // Set the color of the underline here
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black87, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: AppFonts.alatsiRegular,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  String newStudentNumber =
                                  studentNumberController.text.trim();
                                  // Implement saving logic here
                                  if (newStudentNumber.isNotEmpty &&
                                      RegExp(r'^\d{2}-\d{4}-\d{6}$').hasMatch(newStudentNumber)) {
                                    ref.update({'studentNumber': newStudentNumber}).then((_) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                          Text('Student number updated successfully'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                          Text('Failed to update student number'),
                                        ),
                                      );
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter a valid student number (e.g., 03-2122-031040)'),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: AppFonts.alatsiRegular,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          color: CupertinoColors.systemIndigo,
                        ),
                        SizedBox(width: 10),
                        Text('Student Number:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(
                      map['studentNumber'] ?? '',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  ListTile(
                    onTap: () {
                      // Handle Phone tap
                      // For example, show a dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController phoneController =
                          TextEditingController(text: map['phone'] ?? '');
                          return AlertDialog(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            title: Text('Edit Phone', style: TextStyle(fontWeight: FontWeight.bold),),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                  cursorColor: Colors.black87,
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Enter phone number',
                                    // Set the color of the underline here
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey), // Change this to the color you want
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black87, width: 2), // Change this to the color you want
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
                              ),
                              TextButton(
                                onPressed: () {
                                  String newPhone =
                                  phoneController.text.trim();
                                  // Implement saving logic here
                                  if (newPhone.isNotEmpty &&
                                      newPhone.length == 11 &&
                                      int.tryParse(newPhone) != null) {
                                    ref.update({'phone': newPhone}).then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Phone number updated successfully')),
                                      );
                                      Navigator.pop(context);
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to update phone number')),
                                      );
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please enter a valid 11-digit phone number')),
                                    );
                                  }
                                },
                                child: Text('Save', style: TextStyle(color: Colors.black87, fontFamily: AppFonts.alatsiRegular),),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.phone_fill,
                            color: CupertinoColors.activeOrange),
                        SizedBox(width: 10),
                        Text('Phone:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(map['phone'] ?? '',
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    onTap: () {
                      // Handle Email tap
                      // For example, show a dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                            backgroundColor: Colors.white,
                            title: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: GestureDetector(
                              onTap: () {
                                String userName = map['userName']; // Assuming userName is defined and has a value
                                String email = map['email'];
                                if (email.isNotEmpty) {
                                  String subject = 'Account Deactivation'; // Replace 'Your Subject Here' with your desired subject
                                  String message = '''
Hello ${userName},

We regret to inform you that your account has been deactivated. If you have any
questions or concerns, please do not hesitate
to contact us. Thank you for your understanding.

Best regards,
EduVantage Team, InnoVxion Labs
''';
                                  String mailtoUrl = 'mailto:$email?subject=$subject&body=$message';
                                  launchUrlString(mailtoUrl);
                                }
                              },
                              child: Text(
                                map['email'] ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: AppFonts.alatsiRegular,
                                  ),
                                ),
                              ),
                            ],
                          );

                        },
                      );

                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.mail_solid,
                            color: CupertinoColors.systemPurple),
                        SizedBox(width: 10),
                        Text('Email:',
                            style: TextStyle(
                                fontFamily: AppFonts.alatsiRegular,
                                fontSize: 14,
                                color: Colors.black54)),
                      ],
                    ),
                    title: Text(map['email'] ?? '',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.interests_rounded,
                            color: CupertinoColors.systemMint),
                        SizedBox(width: 10),
                        Text('Interests:',
                            style: TextStyle(
                              fontFamily: AppFonts.alatsiRegular,
                              fontSize: 14,
                              color: Colors.black54,
                            )),
                      ],
                    ),
                    title: Text(
                      map['interests'] != null && (map['interests'] as List).isNotEmpty
                          ? map['interests'] != null ? map['interests'].join(', ') : ''
                          : 'No interests',
                      style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
SizedBox(height: 100),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: UserActivityScreen(userUID: userId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black, // text color
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // button border radius
                        ),
                      ),
                      child: Text(
                        'View User Activity',
                        style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 14, // text size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}

