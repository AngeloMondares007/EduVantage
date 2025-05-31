import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:tech_media/res/fonts.dart';

class EditFlashcardCategory extends StatefulWidget {
  final String categoryName;

  EditFlashcardCategory({required this.categoryName});

  @override
  _EditFlashcardCategoryState createState() => _EditFlashcardCategoryState();
}

class _EditFlashcardCategoryState extends State<EditFlashcardCategory> {
  final CollectionReference flashcardCollection =
  FirebaseFirestore.instance.collection('Flashcards');
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _categoryNameController;
  late TextEditingController _categoryDescriptionController;

  Color selectedColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and fetch existing category data
    _categoryNameController = TextEditingController();
    _categoryDescriptionController = TextEditingController();
    fetchCategoryData();
  }

  void fetchCategoryData() async {
    try {
      DocumentSnapshot categoryDoc =
      await flashcardCollection.doc(widget.categoryName).get();

      Map<String, dynamic>? data =
      categoryDoc.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          _categoryNameController.text = data['categoryName'];
          _categoryDescriptionController.text = data['categoryDescription'];
          selectedColor =
              Color(int.parse(data['backgroundColor'], radix: 16));
        });
      }
    } catch (error) {
      print('Error fetching category data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.categoryName}', // Dynamically set the title
          style: TextStyle(color: Colors.black87),
        ),
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

                // TextFormField(
                //   controller: _categoryNameController,
                //   decoration: InputDecoration(labelText: 'Category Name'),
                //   validator: (value) {
                //     if (value?.isEmpty ?? true) {
                //       return 'Please enter a category name';
                //     }
                //     return null;
                //   },
                // ),

                TextFormField(
                  controller: _categoryDescriptionController,
                  decoration:
                  InputDecoration(labelText: 'Category Description'),
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
                        // Update category data
                        updateFlashcardData();

                        // Navigate back
                        Navigator.of(context).pop();
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
                        "Update Category",
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

  void updateFlashcardData() {
    // Use the category name as the document ID
    DocumentReference categoryRef = flashcardCollection.doc(_categoryNameController.text);

    categoryRef.update({
      'categoryName': _categoryNameController.text,
      'categoryDescription': _categoryDescriptionController.text,
      'backgroundColor': selectedColor.value.toRadixString(16),
    }).then((_) {
      print('Flashcard updated in Firestore');
    }).catchError((error) {
      print('Error updating flashcard in Firestore: $error');
    });
  }
}
