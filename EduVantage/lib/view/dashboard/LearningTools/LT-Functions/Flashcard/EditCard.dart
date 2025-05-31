import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../../res/components/CircularProgress.dart';

class EditCardScreen extends StatefulWidget {
  final String categoryName;
  final String cardId;
  final String initialQuestion;
  final String initialAnswer;
  final String? initialQuestionImageURL;
  final String? initialAnswerImageURL;

  EditCardScreen({
    required this.categoryName,
    required this.cardId,
    required this.initialQuestion,
    required this.initialAnswer,
    this.initialQuestionImageURL,
    this.initialAnswerImageURL,
  });

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  File? _questionImage;
  File? _answerImage;
  String? _currentQuestionImageURL;
  String? _currentAnswerImageURL;

  @override
  void initState() {
    super.initState();
    questionController.text = widget.initialQuestion;
    answerController.text = widget.initialAnswer;
    _currentQuestionImageURL = widget.initialQuestionImageURL;
    _currentAnswerImageURL = widget.initialAnswerImageURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Card"),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFe5f3fd),
      resizeToAvoidBottomInset: false, // Set this property to false
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_currentQuestionImageURL != null || _questionImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _questionImage != null
                      ? Image.file(
                    _questionImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    _currentQuestionImageURL!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera, isQuestionImage: true); // Open camera
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(30, 30), // Adjust the minimum size of the button
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(Icons.camera_alt, size: 15),
                    ),
                  ),
                  SizedBox(width: 7),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery, isQuestionImage: true); // Open gallery
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(30, 30), // Adjust the minimum size of the button
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(Icons.photo_library, size: 15,),
                    ),
                  ),
                  SizedBox(width: 7),
                  if (_currentQuestionImageURL != null || _questionImage != null)
                    ElevatedButton(
                      onPressed: () {
                        _removeImage(isQuestionImage: true);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(30, 30), // Adjust the minimum size of the button
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(Icons.delete, size: 15,),
                      ),
                    ),
                ],
              ),
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Edit Question'),
              ),
              SizedBox(height: 16),
              if (_currentAnswerImageURL != null || _answerImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _answerImage != null
                      ? Image.file(
                    _answerImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    _currentAnswerImageURL!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera, isQuestionImage: false); // Open camera
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(30, 30), // Adjust the minimum size of the button
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(Icons.camera_alt, size: 15,),
                    ),
                  ),
                  SizedBox(width: 7),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery, isQuestionImage: false); // Open gallery
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(30, 30), // Adjust the minimum size of the button
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(Icons.photo_library, size: 15,),
                    ),
                  ),
                  SizedBox(width: 7),
                  if (_currentAnswerImageURL != null || _answerImage != null)
                    ElevatedButton(
                      onPressed: () {
                        _removeImage(isQuestionImage: false);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(30, 30), // Adjust the minimum size of the button
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(Icons.delete, size: 15,),
                      ),
                    ),
                ],
              ),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Edit Answer'),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    updateCard();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0, backgroundColor: Colors.black87.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "Update Card",
                      style: TextStyle(
                        fontFamily: AppFonts.alatsiRegular,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source, {required bool isQuestionImage}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        if (isQuestionImage) {
          _questionImage = File(pickedImage.path);
          _currentQuestionImageURL = null; // Clear current image URL
        } else {
          _answerImage = File(pickedImage.path);
          _currentAnswerImageURL = null; // Clear current image URL
        }
      });
    }
  }

  void _removeImage({required bool isQuestionImage}) {
    setState(() {
      if (isQuestionImage) {
        _questionImage = null;
        _currentQuestionImageURL = null;
      } else {
        _answerImage = null;
        _currentAnswerImageURL = null;
      }
    });
  }

  void updateCard() async {

    ProgressDialog.show(context, message: 'Updating card...', icon: Icons.save_as_rounded);

    String updatedQuestion = questionController.text.trim();
    String updatedAnswer = answerController.text.trim();
    String? updatedQuestionImageURL;
    String? updatedAnswerImageURL;

    if (_questionImage != null) {
      updatedQuestionImageURL = await uploadImage(_questionImage!);
    } else {
      updatedQuestionImageURL = _currentQuestionImageURL;
    }

    if (_answerImage != null) {
      updatedAnswerImageURL = await uploadImage(_answerImage!);
    } else {
      updatedAnswerImageURL = _currentAnswerImageURL;
    }

    if (updatedQuestion.isNotEmpty && updatedAnswer.isNotEmpty) {
      // Update the card in Firestore
      FirebaseFirestore.instance
          .collection('Flashcards')
          .doc(widget.categoryName)
          .collection('cards')
          .doc(widget.cardId)
          .update({
        'question': updatedQuestion,
        'answer': updatedAnswer,
        'questionImageURL': updatedQuestionImageURL,
        'answerImageURL': updatedAnswerImageURL,
      })
          .then((_) {
        print('Card updated in Firestore');
        Fluttertoast.showToast(
          msg: "Card updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue.shade800,
          textColor: Colors.white,
        );
        Navigator.pop(context); // Close the EditCardScreen after updating
      })
          .catchError((error) {
        print('Error updating card in Firestore: $error');
      });
    }

    ProgressDialog.hide(context);

  }

  // Function to upload image to Firebase Cloud Storage
  Future<String> uploadImage(File imageFile) async {
    // Create a reference to the location you want to upload to in Firebase Cloud Storage
    Reference storageReference =
    FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the file to Firebase Cloud Storage
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Await for the upload to complete and return the download URL
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }
}
