import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_media/view/login/login_screen.dart';
import 'package:tech_media/view_model/profile/profile_controller.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../res/fonts.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ref = FirebaseDatabase.instance.ref('User');
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black87,
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: AppFonts.alatsiRegular,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFe5f3fd),
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context, provider, child) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: StreamBuilder(
                    stream: ref
                        .child(SessionController().userId.toString())
                        .onValue,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data.snapshot.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 300),
                              Text('No data available'),
                              RoundButton(
                                title: 'Logout',
                                color: Colors.white70.withOpacity(0),
                                textColor: Colors.red,
                                onPress: () async {
                                  // Show confirmation dialog for logout
                                  await _confirmLogout(context);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        Map<dynamic, dynamic> map =
                            snapshot.data.snapshot.value;
                        print(map.toString());
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Show full-size image when tapped
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          child: CachedNetworkImage(
                                            imageUrl: map['profile'] ?? '',
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget: (context, url, error) =>
                                                Icon(Icons.no_photography_rounded, color: Colors.red, size: 30,),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Container(
                                        height: 160,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black12)
                                            ],
                                            border: Border.all(
                                              color: Colors.transparent,
                                            )
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: provider.image == null
                                              ? (map['profile'].toString() == ""
                                              ? const Icon(
                                            CupertinoIcons.person_alt,
                                            size: 100,
                                            color: Color(0xFFe5f3fd),
                                          )
                                              : CachedNetworkImage(
                                            imageUrl: map['profile'].toString(),
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                            errorWidget: (context, url, error) => Container(
                                              child: Icon(
                                                Icons.error_outline,
                                                color: AppColors.alertColor,
                                              ),
                                            ),
                                          ))
                                              : Stack(
                                            children: [
                                              Image.file(
                                                File(provider.image!.path).absolute,
                                              ),
                                              Center(
                                                child: CircularProgressIndicator(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    provider.pickImage(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                    Colors.black87.withOpacity(0.8),
                                    child: Icon(CupertinoIcons.camera_fill,
                                        size: 14, color: Color(0xFFe5f3fd)),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              map['userName'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                provider.showUserNameDialogAlert(
                                    context, map['userName']);
                              },
                              child: ReusableRow(
                                title: 'Username',
                                value: map['userName'],
                                iconData: CupertinoIcons.person_alt,
                                iconColor: CupertinoColors.activeBlue,
                              ),
                            ),
                            GestureDetector(
                              // onTap: () {
                              //   Utils.toastMessage('This can be only edited by the admin');
                              // },
                              child: ReusableRow(
                                title: 'School',
                                value: map['department'],
                                iconData: Icons.account_balance_rounded,
                                iconColor: CupertinoColors.destructiveRed,
                              ),
                            ),
                            GestureDetector(
                              // onTap: () {
                              //   Utils.toastMessage('This can be only edited by the admin');
                              // },
                              child: ReusableRow(
                                title: 'Department',
                                value: map['course'],
                                iconData: Icons.book_rounded,
                                iconColor: CupertinoColors.activeGreen,
                              ),
                            ),
                            GestureDetector(
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
                              child: ReusableRow(
                                title: 'Student Number',
                                value: map['studentNumber'],
                                iconData: Icons.person_pin_rounded,
                                iconColor: CupertinoColors.systemIndigo ,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                provider.showPhoneDialogAlert(
                                    context, map['phone']);
                              },
                              child: ReusableRow(
                                title: 'Phone',
                                value: map['phone'] == ''
                                    ? 'xxx-xxx-xxx'
                                    : map['phone'],
                                iconData: CupertinoIcons.phone_fill,
                                iconColor: CupertinoColors.activeOrange,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle the tap event here, you can show details in a dialog or navigate to a new screen
                                // For example, showing details in a dialog:
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
                                        "Email",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: GestureDetector(
                                        onTap: () {
                                          String email = map['email'];
                                          if (email.isNotEmpty) {
                                            String mailtoUrl = 'mailto:$email';
                                            launchUrlString(mailtoUrl);
                                          }
                                        },
                                        child: Text(
                                          "${map['email']}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blueAccent,
                                            decoration: TextDecoration.none,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          child: Text(
                                            "Close",
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
                              child: ReusableRow(
                                title: 'Email',
                                value: map['email'],
                                iconData: CupertinoIcons.mail_solid,
                                iconColor: CupertinoColors.systemPurple,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle the tap event for Interests here

                              },
                              child: ReusableRow(
                                title: 'Interests',
                                value: map['interests'] != null ? map['interests'].join(', ') : '', // Assuming interests is a list of strings
                                iconData: Icons.interests_rounded,
                                iconColor: CupertinoColors.systemMint,
                              ),
                            ),

                            // ReusableRow(
                            //   title: 'Role', // Display the user's role
                            //   value: userRole,
                            //   iconData: CupertinoIcons.person_2_alt,
                            //   iconColor: Colors.blue.withOpacity(0.9),
                            // ),
                            const SizedBox(
                              height: 50,
                            ),
                            RoundButton(
                              title: 'Logout',
                              color: Color(0xFFe5f3fd),
                              textColor: Colors.red,
                              onPress: () async {
                                // Show confirmation dialog for logout
                                await _confirmLogout(context);
                              },
                            )
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 16,
                fontWeight: FontWeight.w100),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Sign out the user
                await auth.signOut();

                // Navigate to LoginScreen and remove all routes below it
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 16,
                    color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without logging out
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 16,
                    color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ReusableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  final Color iconColor;
  const ReusableRow({
    Key? key,
    required this.title,
    required this.iconData,
    required this.value,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w200,
                color: Colors.black87.withOpacity(0.5)), softWrap: true, overflow: TextOverflow.ellipsis,),
          leading: Icon(iconData, color: iconColor),
          trailing: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.alatsiRegular,
            )
            ,softWrap: true, overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
