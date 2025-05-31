import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/EditCard.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../res/components/CircularProgress.dart';
import '../../../../../res/fonts.dart';

class EditAddCardScreen extends StatefulWidget {
  final String categoryName;
  final Color selectedColor;

  EditAddCardScreen({required this.categoryName, required this.selectedColor});

  @override
  _EditAddCardScreenState createState() => _EditAddCardScreenState();
}

class _EditAddCardScreenState extends State<EditAddCardScreen> {
  List<Map<String, String>> cards = [];
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  File? _questionImage;
  File? _answerImage;
  bool isAddingCard = false; // Add this flag

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Cards for ${widget.categoryName}",
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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
          ),
        ],
      ),
      backgroundColor: Color(0xFFe5f3fd),
      resizeToAvoidBottomInset: false, // Set this property to false
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _pickImage(ImageSource.camera, isQuestionImage: true);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Icon(Icons.camera_alt, size: 20,),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          _pickImage(ImageSource.gallery, isQuestionImage: true);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Icon(Icons.photo_library_rounded, size: 20,),
                      ),
                      SizedBox(width: 15),
                      _questionImage != null
                          ? Stack(
                        children: [
                          Image.file(
                            _questionImage!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              color: Colors.red,
                              onPressed: () {
                                _removeImage(isQuestionImage: true);
                              },
                            ),
                          ),
                        ],
                      )
                          : SizedBox.shrink(),
                    ],
                  ),
                  TextFormField(
                    controller: questionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a question';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Enter Question'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _pickImage(ImageSource.camera, isQuestionImage: false);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Icon(Icons.camera_alt, size: 20,),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          _pickImage(ImageSource.gallery, isQuestionImage: false);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Icon(Icons.photo_library_rounded, size: 20,),
                      ),
                      SizedBox(width: 15),
                      _answerImage != null
                          ? Stack(
                        children: [
                          Image.file(
                            _answerImage!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              color: Colors.red,
                              onPressed: () {
                                _removeImage(isQuestionImage: false);
                              },
                            ),
                          ),
                        ],
                      )
                          : SizedBox.shrink(),
                    ],
                  ),
                  TextFormField(
                    controller: answerController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an answer';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Enter Answer'),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addCard();
                        }
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
                          "Add Card",
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
                  SizedBox(height: 10)
                ],
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Flashcards')
                      .doc(widget.categoryName)
                      .collection('cards')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    var cardDocs = snapshot.data?.docs ?? [];
                    cardDocs = cardDocs.reversed.toList();
                    List<Widget> cardWidgets = [];

                    for (var card in cardDocs) {
                      var cardData = card.data() as Map<String, dynamic>;

                      cardWidgets.add(
                        Card(
                          elevation: 0,
                          color: Colors.green,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Question: ${cardData['question']}',
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                                SizedBox(height: 8),
                                if (cardData['questionImageURL'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Image.network(
                                      cardData['questionImageURL'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Text(
                                  'Answer: ${cardData['answer']}',
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                                SizedBox(height: 8),
                                if (cardData['answerImageURL'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Image.network(
                                      cardData['answerImageURL'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      onPressed: () {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: EditCardScreen(
                                            categoryName: widget.categoryName,
                                            cardId: card.id,
                                            initialQuestion: cardData['question'],
                                            initialAnswer: cardData['answer'],
                                            initialAnswerImageURL : cardData['answerImageURL'],
                                            initialQuestionImageURL: cardData['questionImageURL'],
                                          ),
                                          withNavBar: true,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.white),
                                      onPressed: () {
                                        onDeleteCard(card.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      );
                    }

                    return ListView(
                      children: cardWidgets,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, {required bool isQuestionImage}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        if (isQuestionImage) {
          _questionImage = File(pickedImage.path);
        } else {
          _answerImage = File(pickedImage.path);
        }
      });
    }
  }


  void addCard() async {

    ProgressDialog.show(context, message: 'Adding card...', icon: Icons.save_as_rounded);

    if (isAddingCard) {
      return; // Prevent multiple clicks
    }

    setState(() {
      isAddingCard = true; // Set flag to indicate card addition process has started
    });

    String question = questionController.text.trim();
    String answer = answerController.text.trim();
    String? questionImageURL;
    String? answerImageURL;

    if (_questionImage != null) {
      questionImageURL = await uploadImage(_questionImage!);
    }
    if (_answerImage != null) {
      answerImageURL = await uploadImage(_answerImage!);
    }

    if (question.isNotEmpty && answer.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Flashcards')
          .doc(widget.categoryName)
          .collection('cards')
          .add({
        'question': question,
        'answer': answer,
        'questionImageURL': questionImageURL,
        'answerImageURL': answerImageURL,
        'timestamp': FieldValue.serverTimestamp(),
      })
          .then((_) {
        print('Card added to Firestore');
        questionController.clear();
        answerController.clear();
        setState(() {
          _questionImage = null;
          _answerImage = null;
          isAddingCard = false; // Reset flag after successful addition
        });

        Fluttertoast.showToast(
          msg: "Flashcard added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue.shade800,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      })
          .catchError((error) {
        print('Error adding card to Firestore: $error');
        setState(() {
          isAddingCard = false; // Reset flag if there's an error
        });
      });
    } else {
      setState(() {
        isAddingCard = false; // Reset flag if input validation fails
      });
    }

    ProgressDialog.hide(context);

  }

  Future<String> uploadImage(File imageFile) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    UploadTask uploadTask = storageReference.putFile(imageFile);

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  }

  void onDeleteCard(String cardId) {
    FirebaseFirestore.instance
        .collection('Flashcards')
        .doc(widget.categoryName)
        .collection('cards')
        .doc(cardId)
        .delete()
        .then((_) {
      Fluttertoast.showToast(
        msg: "Flashcard deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue.shade800,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Card deleted from Firestore');
    })
        .catchError((error) {
      Fluttertoast.showToast(
        msg: "Failed to delete flashcard: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Error deleting card from Firestore: $error');
    });
  }

  void saveCardsData() {
    // Navigate back to the previous screen
    Navigator.pop(context);
    // Navigate back to the previous previous screen
    Navigator.pop(context);
  }

  void _removeImage({required bool isQuestionImage}) {
    setState(() {
      if (isQuestionImage) {
        _questionImage = null;
      } else {
        _answerImage = null;
      }
    });
  }
}
