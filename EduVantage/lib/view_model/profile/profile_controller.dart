import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

import '../../view/dashboard/profile/cropper.dart';

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

  // Function to validate name format
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    // Check if the length of the name is greater than 30 characters
    if (value.length > 30) {
      return 'Name cannot be longer than 30 characters';
    }
    // Check if the first character is a capital letter
    if (!RegExp(r'^[A-Z]').hasMatch(value)) {
      return 'Name must start with a capital letter';
    }
    return null;
  }


  Future pickGalleryImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      _image = await cropImage(_image!.path);
      uploadImage(context);
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      _image = await cropImage(_image!.path);
      uploadImage(context);
      notifyListeners();
    }
  }

  void pickImage(context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.white,
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
                    leading: Icon (CupertinoIcons.camera_fill, color: CupertinoColors.destructiveRed,),
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

  Future<void> showUserNameDialogAlert(BuildContext context, String name) {
    nameController.text = name;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Color(0xFFe5f3fd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Update username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
          content: SingleChildScrollView(
            child: ListView(
              shrinkWrap: true,
              children: [
                InputTextField(
                  myController: nameController,
                  focusNode: nameFocusNode,
                  onFiledSubmitValue: (value) {},
                  keyBoardType: TextInputType.text,
                  obscureText: false,
                  hint: 'Enter name',
                  onValidator: (value) => validateName(value), // Using modified validation function
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
                style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Validate the name before updating
                  String? validationResult = validateName(nameController.text);
                  if (validationResult == null) {
                    ref.child(SessionController().userId.toString()).update({
                      'userName': nameController.text.toString(),
                    }).then((value) {
                      nameController.clear();
                      Navigator.pop(context);
                      Utils.toastMessage('Username updated');
                    });
                  } else {
                    Utils.toastMessage(validationResult);
                  }
                } else {
                  Utils.toastMessage('Name cannot be empty');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.black87, fontFamily: AppFonts.alatsiRegular, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showPhoneDialogAlert(BuildContext context, String phoneNumber) {
    phoneController.text = phoneNumber;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Color(0xFFe5f3fd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Update phone number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
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
                style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                if (phoneController.text.length == 11) {
                  ref.child(SessionController().userId.toString()).update({
                    'phone': phoneController.text.toString(),
                  }).then((value) {
                    phoneController.clear();
                    Navigator.pop(context);
                    Utils.toastMessage('Phone number updated');
                  });
                } else {
                  Utils.toastMessage('Phone number must be exactly 11 digits');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.black87, fontFamily: AppFonts.alatsiRegular, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }




}
