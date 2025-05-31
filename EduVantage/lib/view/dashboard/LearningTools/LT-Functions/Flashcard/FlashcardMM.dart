import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/AddFlashcardCategory.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/EditCategory.dart';
import '../../../../../res/fonts.dart';
import '../../../../../utils/utils.dart';
import 'EditAddCard.dart';
import 'FlashcardPlayScreen.dart';

void main() {
  runApp(MyApp());
}

void navigateToFlashcardPlayScreen(
    BuildContext context, {
      required String categoryName,
      required String categoryDescription,
    }) {
  PersistentNavBarNavigator.pushNewScreen(
    context,
    screen: FlashcardPlayScreen(
      categoryName: categoryName,
      categoryDescription: categoryDescription,
    ),
    withNavBar: false,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: FlashcardMainMenu(userUID: '',),
    );
  }
}

class FlashcardMainMenu extends StatefulWidget {
  final String userUID;
  FlashcardMainMenu({required this.userUID});
  @override
  State<FlashcardMainMenu> createState() => _FlashcardMainMenuState(userUID: userUID);
}

class _FlashcardMainMenuState extends State<FlashcardMainMenu> {
  final String userUID;
  _FlashcardMainMenuState({required this.userUID});
  List<FlashcardCard> flashcardWidgets = [];

  Future<void> _refreshData() async {
    // Implement your refresh logic here
    // For example, you can refetch data from Firestore
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay, replace this with your actual data fetching logic
  }

  @override
  void initState() {
    super.initState();
    log(widget.userUID);
  }

  void deleteCard(BuildContext context, String categoryName) {
    // Implement the deletion logic
    FirebaseFirestore.instance
        .collection('Flashcards')
        .doc(categoryName)
        .delete()
        .then((_) {
      print('Card deleted from Firestore');
      // Remove the card from the UI
      setState(() {
        flashcardWidgets.removeWhere((card) => card.categoryName == categoryName);
      });
    }).catchError((error) {
      print('Error deleting card from Firestore: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Flashcards',
          style: TextStyle(
            fontFamily: AppFonts.alatsiRegular,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Flashcards').where('userUID', isEqualTo: widget.userUID).snapshots(),
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

              var flashcardDocs = snapshot.data?.docs ?? [];
              flashcardWidgets = [];

              for (var flashcard in flashcardDocs) {
                var flashcardData = flashcard.data() as Map<String, dynamic>;
                flashcardWidgets.add(
                  FlashcardCard(
                    categoryName: flashcardData['categoryName'],
                    categoryDescription: flashcardData['categoryDescription'],
                    backgroundColor: flashcardData['backgroundColor'],
                    onPressed: () {
                      navigateToFlashcardPlayScreen(
                        context,
                        categoryName: flashcardData['categoryName'],
                        categoryDescription: flashcardData['categoryDescription'],
                      );
                    },
                    onDelete: () {
                      deleteCard(context, flashcardData['categoryName']);
                    },
                  ),
                );
              }

              if (flashcardWidgets.isEmpty) {
                return Center(
                  child: Text('No flashcards found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black45),),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: flashcardWidgets.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        flashcardWidgets[index],
                        SizedBox(height: 3), // Added more space between cards
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: AddFlashcardCategory(userUID: widget.userUID),
            withNavBar: false,
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.yellow.shade800,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


class FlashcardCard extends StatelessWidget {

  final String categoryName;
  final String categoryDescription;
  final String backgroundColor;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  FlashcardCard({
    required this.categoryName,
    required this.categoryDescription,
    required this.backgroundColor,
    required this.onPressed,
    required this.onDelete,
  });

  void navigateToAddCardScreen(BuildContext context, {required String categoryName}) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EditAddCardScreen(categoryName: categoryName, selectedColor: Colors.blue),
      withNavBar: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    Color cardColor = Color(int.parse(backgroundColor, radix: 16));
    double luminance = cardColor.computeLuminance();
    Color textColor = luminance > 0.5 ? Colors.black : Colors.white;
    Color subTextColor = luminance > 0.5 ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9);

    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 150,
        width: 350,
        child: Card(
          color: Color(int.parse(backgroundColor, radix: 16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$categoryName',
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
                    ),
                    PopupMenuButton(
                      color: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      icon: Icon(Icons.more_vert, color: textColor),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAddCardScreen(context, categoryName: categoryName);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Add', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular)),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: EditFlashcardCategory(categoryName: categoryName),
                                withNavBar: false,
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white,),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular)),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                    ),
                                    title: Text('Confirm Deletion', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.bold, fontSize: 24),),
                                    content: Text('Are you sure you want to delete this card?', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.normal, fontSize: 14)),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close the dialog
                                        },
                                        child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          onDelete();
                                          Navigator.pop(context); // Close the dialog
                                          Utils.toastMessage('Flashcard category deleted');
                                        },
                                        child: Text('Delete', style: TextStyle(color: Colors.black87, fontFamily: AppFonts.alatsiRegular)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.white,),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.white, fontFamily: AppFonts.alatsiRegular)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  '$categoryDescription',
                  style: TextStyle(fontWeight: FontWeight.normal, color: subTextColor, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}