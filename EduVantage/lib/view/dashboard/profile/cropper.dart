import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> cropImage(String imagePath) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imagePath,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
      uiSettings: [
      AndroidUiSettings(
      toolbarTitle: 'Image Cropper',
      toolbarColor: Colors.black,
      toolbarWidgetColor: Colors.white,
      activeControlsWidgetColor: Colors.green,
      initAspectRatio: CropAspectRatioPreset.square,
      lockAspectRatio: true),
      IOSUiSettings(
  title: 'Image Cropper',
  ),
  ]);

  if (croppedFile != null) {
    return XFile(croppedFile.path);
  } else {
    return null;
  }
}

