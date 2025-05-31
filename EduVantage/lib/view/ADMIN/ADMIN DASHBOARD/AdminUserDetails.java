import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

import '../../res/color.dart';

class ProfileController with ChangeNotifier {


    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    final nameFocusNode = FocusNode();
    final phoneFocusNode = FocusNode();

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    final picker = ImagePicker();

    XFile? _image;
    XFile? get image => _image;

    bool _loading = false;
    bool get loading => _loading;

    setLoading(bool value){
        _loading = value;
        notifyListeners();

    }


    Future pickGalleryImage(BuildContext context)async{
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

        if (pickedFile != null) {
            _image = XFile(pickedFile.path);
            uploadImage(context);
            notifyListeners();
        }
    }

    Future pickCameraImage(BuildContext context)async{
        final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);

        if (pickedFile != null) {
            _image = XFile(pickedFile.path);
            uploadImage(context);
            notifyListeners();
        }
    }


    void pickImage(context){
        showDialog(
                context: context,
                builder: (BuildContext context){
            return AlertDialog(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
          ),
            content: Container(
                    height: 120,
                    child: Column(
                    children: [

            ListTile(
                    onTap: (){
                Navigator.pop(context);
                pickCameraImage(context);
            },
            leading: Icon (CupertinoIcons.camera_fill, color: CupertinoColors.activeBlue,),
            title: Text('Camera'),
                  ),

            ListTile(
                    onTap: (){
                Navigator.pop(context);
                pickGalleryImage(context);
            },
            leading: Icon (CupertinoIcons.photo_fill_on_rectangle_fill, color: CupertinoColors.activeBlue,),
            title: Text('Gallery'),
                  ),



                ],
              ),
          ),
        );
        }
    );
    }

    void uploadImage(BuildContext context) async {

        setLoading(true);
        firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref('/profileImage'+SessionController().userId.toString());

        firebase_storage.UploadTask uploadTask = storageRef.putFile(File(image!.path).absolute);

        await Future.value(uploadTask);
        final newUrl = await storageRef.getDownloadURL();

        ref.child(SessionController().userId.toString()).update({
                'profile' : newUrl.toString()
    }).then((value){
                Utils.toastMessage('Profile picture updated');
        setLoading(false);
        _image = null;

    }).onError((error, stackTrace){
            Utils.toastMessage(error.toString());
            setLoading(false);
        });

    }

    Future<void> showUserNameDialogAlert(BuildContext context, String name){
        nameController.text = name;
        return showDialog(context: context,
                builder: (context){
        return AlertDialog(
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
        ),
        title: const Center(child: Text('Update username')),
        content:SingleChildScrollView(
                child: ListView(
                shrinkWrap: true,
                children: [
        InputTextField(myController: nameController,
                focusNode: nameFocusNode,
                onFiledSubmitValue: (value){

        },
                keyBoardType: TextInputType.text,
                obscureText: false,
                hint: 'Enter name',
                onValidator: (value){
        return null;


                  }

              )],
          ),
        ),
        actions: [
        TextButton(onPressed: (){
            Navigator.pop(context);
        }, child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.alertColor),)),
        TextButton(onPressed: (){

            ref.child(SessionController().userId.toString()).update({
                    'userName' : nameController.text.toString()
            }).then((value) {
                    nameController.clear();
            });
            Navigator.pop(context);
        }, child: Text('OK', style: Theme.of(context).textTheme.bodySmall,))

        ],

      );

        }

    );
    }

    Future<void> showPhoneDialogAlert(BuildContext context, String phoneNumber) {
        phoneController.text = phoneNumber;
        return showDialog(
                context: context,
                builder: (context) {
        return AlertDialog(
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
          ),
        title: const Center(child: Text('Update phone number')),
        content: SingleChildScrollView(
                child: ListView(
                shrinkWrap: true,
                children: [
        InputTextField(
                myController: phoneController,
                focusNode: phoneFocusNode,
                onFiledSubmitValue: (value) {},
                keyBoardType: TextInputType.phone,
                obscureText: false,
                hint: 'Enter phone',
                onValidator: (value) {
        // Validate the phone number length
        if (value!.length != 11) {
            return 'Phone number must be exactly 11 digits';
        }
        return null;
                  },
                ),
              ],
            ),
          ),
        actions: [
        TextButton(
                onPressed: () {
            Navigator.pop(context);
        },
        child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.alertColor),
              ),
            ),
        TextButton(
                onPressed: () {
            if (phoneController.text.length == 11) {
                ref.child(SessionController().userId.toString()).update({
                        'phone': phoneController.text.toString(),
                  }).then((value) {
                        phoneController.clear();
                  });
                Navigator.pop(context);
            } else {
                Utils.toastMessage('Phone number must be exactly 11 digits');
            }
        },
        child: Text(
                'OK',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
    }



}
import 'dart:io';
        import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
        import 'package:firebase_database/firebase_database.dart';
        import 'package:flutter/cupertino.dart';
        import 'package:flutter/material.dart';
        import 'package:image_picker/image_picker.dart';
        import 'package:tech_media/res/components/input_text_field.dart';
        import 'package:tech_media/utils/utils.dart';
        import 'package:tech_media/view_model/services/session_manager.dart';

        import '../../res/color.dart';

class ProfileController with ChangeNotifier {


    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    final nameFocusNode = FocusNode();
    final phoneFocusNode = FocusNode();

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    final picker = ImagePicker();

    XFile? _image;
    XFile? get image => _image;

    bool _loading = false;
    bool get loading => _loading;

    setLoading(bool value){
        _loading = value;
        notifyListeners();

    }


    Future pickGalleryImage(BuildContext context)async{
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

        if (pickedFile != null) {
            _image = XFile(pickedFile.path);
            uploadImage(context);
            notifyListeners();
        }
    }

    Future pickCameraImage(BuildContext context)async{
        final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);

        if (pickedFile != null) {
            _image = XFile(pickedFile.path);
            uploadImage(context);
            notifyListeners();
        }
    }


    void pickImage(context){
        showDialog(
                context: context,
                builder: (BuildContext context){
            return AlertDialog(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
          ),
            content: Container(
                    height: 120,
                    child: Column(
                    children: [

            ListTile(
                    onTap: (){
                Navigator.pop(context);
                pickCameraImage(context);
            },
            leading: Icon (CupertinoIcons.camera_fill, color: CupertinoColors.activeBlue,),
            title: Text('Camera'),
                  ),

            ListTile(
                    onTap: (){
                Navigator.pop(context);
                pickGalleryImage(context);
            },
            leading: Icon (CupertinoIcons.photo_fill_on_rectangle_fill, color: CupertinoColors.activeBlue,),
            title: Text('Gallery'),
                  ),



                ],
              ),
          ),
        );
        }
    );
    }

    void uploadImage(BuildContext context) async {

        setLoading(true);
        firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref('/profileImage'+SessionController().userId.toString());

        firebase_storage.UploadTask uploadTask = storageRef.putFile(File(image!.path).absolute);

        await Future.value(uploadTask);
        final newUrl = await storageRef.getDownloadURL();

        ref.child(SessionController().userId.toString()).update({
                'profile' : newUrl.toString()
    }).then((value){
                Utils.toastMessage('Profile picture updated');
        setLoading(false);
        _image = null;

    }).onError((error, stackTrace){
            Utils.toastMessage(error.toString());
            setLoading(false);
        });

    }

    Future<void> showUserNameDialogAlert(BuildContext context, String name){
        nameController.text = name;
        return showDialog(context: context,
                builder: (context){
        return AlertDialog(
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
        ),
        title: const Center(child: Text('Update username')),
        content:SingleChildScrollView(
                child: ListView(
                shrinkWrap: true,
                children: [
        InputTextField(myController: nameController,
                focusNode: nameFocusNode,
                onFiledSubmitValue: (value){

        },
                keyBoardType: TextInputType.text,
                obscureText: false,
                hint: 'Enter name',
                onValidator: (value){
        return null;


                  }

              )],
          ),
        ),
        actions: [
        TextButton(onPressed: (){
            Navigator.pop(context);
        }, child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.alertColor),)),
        TextButton(onPressed: (){

            ref.child(SessionController().userId.toString()).update({
                    'userName' : nameController.text.toString()
            }).then((value) {
                    nameController.clear();
            });
            Navigator.pop(context);
        }, child: Text('OK', style: Theme.of(context).textTheme.bodySmall,))

        ],

      );

        }

    );
    }

    Future<void> showPhoneDialogAlert(BuildContext context, String phoneNumber) {
        phoneController.text = phoneNumber;
        return showDialog(
                context: context,
                builder: (context) {
        return AlertDialog(
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
          ),
        title: const Center(child: Text('Update phone number')),
        content: SingleChildScrollView(
                child: ListView(
                shrinkWrap: true,
                children: [
        InputTextField(
                myController: phoneController,
                focusNode: phoneFocusNode,
                onFiledSubmitValue: (value) {},
                keyBoardType: TextInputType.phone,
                obscureText: false,
                hint: 'Enter phone',
                onValidator: (value) {
        // Validate the phone number length
        if (value!.length != 11) {
            return 'Phone number must be exactly 11 digits';
        }
        return null;
                  },
                ),
              ],
            ),
          ),
        actions: [
        TextButton(
                onPressed: () {
            Navigator.pop(context);
        },
        child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.alertColor),
              ),
            ),
        TextButton(
                onPressed: () {
            if (phoneController.text.length == 11) {
                ref.child(SessionController().userId.toString()).update({
                        'phone': phoneController.text.toString(),
                  }).then((value) {
                        phoneController.clear();
                  });
                Navigator.pop(context);
            } else {
                Utils.toastMessage('Phone number must be exactly 11 digits');
            }
        },
        child: Text(
                'OK',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
    }



}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_edit.dart';
import 'package:tech_media/utils/persistent_nav_bar_navigator.dart';

class AdminUserDetails extends StatelessWidget {
  final String userId;

  const AdminUserDetails({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('User').child(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Text('Profile'),
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
                  CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        CachedNetworkImageProvider(map['profile'] ?? ''),
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
                            title: Text('Username'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter username',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String newUsername =
                                      usernameController.text.trim();
                                  // Implement saving logic here
                                  if (newUsername.isNotEmpty) {
                                    ref.update({'userName': newUsername})
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Username updated successfully')),
                                      );
                                      Navigator.pop(context);
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Failed to update username')),
                                      );
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Username cannot be empty')),
                                    );
                                  }
                                },
                                child: Text('Save'),
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
                      // Handle Phone tap
                      // For example, show a dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController phoneController =
                              TextEditingController(text: map['phone'] ?? '');
                          return AlertDialog(
                            title: Text('Phone'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Enter phone number',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
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
                                child: Text('Save'),
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
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Email:'),
                            content: Text(map['email'] ?? ''),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Close'),
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
                        style: TextStyle(
                            fontFamily: AppFonts.alatsiRegular,
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
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
