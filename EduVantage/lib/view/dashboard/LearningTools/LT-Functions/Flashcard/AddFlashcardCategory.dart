import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/AddCardScreem.dart';


class AddFlashcardCategory extends StatefulWidget {
  final String userUID;
  AddFlashcardCategory({required this.userUID});
  @override
  _AddFlashcardCategoryState createState() => _AddFlashcardCategoryState();
}

class _AddFlashcardCategoryState extends State<AddFlashcardCategory> {
  final CollectionReference flashcardCollection =
  FirebaseFirestore.instance.collection('Flashcards');
  final _formKey = GlobalKey<FormState>();
  String categoryName = '';
  String categoryDescription = '';
  Color selectedColor = Colors.yellow.shade800;
  String? userUID;

  @override
  void initState() {
    super.initState();
    userUID = widget.userUID;
    log(userUID!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category", style: TextStyle(color: Colors.black87)),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Category Name'),
                  onChanged: (value) {
                    setState(() {
                      categoryName = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                  InputDecoration(labelText: 'Category Description'),
                  onChanged: (value) {
                    setState(() {
                      categoryDescription = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a category description';
                    }
                    return null;
                  },
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Pick a color',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: MaterialColorPicker(
                              selectedColor: selectedColor,
                              onColorChange: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              onBack: () {},
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFonts.alatsiRegular,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "Choose Panel Color",
                    style: TextStyle(
                      color: selectedColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.alatsiRegular,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        // Save category data
                        saveFlashcardData();

                        // Navigate to AddCardScreen with category data
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: AddCardScreen(categoryName: categoryName, selectedColor: selectedColor),
                          withNavBar: false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: Colors.black87.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        "Create Category",
                        style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getUserName(String userUID) async {
    try {
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .ref('User')
          .child(userUID)
          .once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map;
        String userName = userData['userName']; // Assuming 'userName' is the key for the user's name
        return userName;
      } else {
        return ''; // Return an empty string if user data is not found
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  Future<void> saveFlashcardData() async {
    // Use the category name as the document ID
    DocumentReference categoryRef = flashcardCollection.doc(categoryName);

    categoryRef.set({
      'categoryName': categoryName,
      'categoryDescription': categoryDescription,
      'userUID': userUID,
      'backgroundColor': selectedColor.value.toRadixString(16),
    }).then((_) {
      print('Flashcard added to Firestore');
    }).catchError((error) {
      print('Error adding flashcard to Firestore: $error');
    });

    FirebaseFirestore.instance.collection('ActivityLogs').add({
      "title": "Flashcard Category Added",
      "activity": '${await getUserName(userUID!)} added a Flashcard Category "${categoryName}"',
      "timestamp": Timestamp.now(),
      "userId": userUID,
    });
  }

}
