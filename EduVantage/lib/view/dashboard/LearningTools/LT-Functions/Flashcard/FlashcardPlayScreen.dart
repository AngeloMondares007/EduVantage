import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../res/fonts.dart';

class FlashcardPlayScreen extends StatefulWidget {
  final String categoryName;
  final String categoryDescription;

  FlashcardPlayScreen({required this.categoryName, required this.categoryDescription});

  @override
  _FlashcardPlayScreenState createState() => _FlashcardPlayScreenState();
}

class _FlashcardPlayScreenState extends State<FlashcardPlayScreen>
    with SingleTickerProviderStateMixin {
  // List to store flashcards retrieved from Firestore
  List<Map<String, String>> flashcards = [];

  // Index of the currently displayed flashcard
  int currentFlashcardIndex = 0;

  // Flag to determine whether to show the question or answer
  bool showAnswer = false;

  late AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;

  @override
  void initState() {
    super.initState();
    // Fetch flashcards from Firestore when the screen initializes
    fetchFlashcards();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _frontRotation = Tween<double>(begin: 0.0, end: 180.0).animate(_controller);
    _backRotation = Tween<double>(begin: 180.0, end: 360.0).animate(_controller);
  }

  // Method to fetch flashcards from Firestore
  void fetchFlashcards() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference flashcardsCollection = firestore.collection('Flashcards');
      DocumentSnapshot categoryDoc = await flashcardsCollection.doc(widget.categoryName).get();

      CollectionReference cardsCollection = categoryDoc.reference.collection('cards');
      QuerySnapshot cardsQuery = await cardsCollection.get();

      flashcards = cardsQuery.docs.map((card) {
        Map<String, dynamic> data = card.data() as Map<String, dynamic>;
        return {
          'question': data['question'].toString(),
          'answer': data['answer'].toString(),
          'answerImageURL': data['answerImageURL'].toString(),
          'questionImageURL': data['questionImageURL'].toString(),
        };
      }).toList();

      print('Fetched flashcards: $flashcards');

      setState(() {});
    } catch (e) {
      print('Error fetching flashcards: $e');
    }
  }

  // Method to shuffle the flashcards
  void shuffleFlashcards() {
    setState(() {
      flashcards.shuffle();
      currentFlashcardIndex = 0;
      showAnswer = false;
      _controller.reverse();
    });
  }

  // Method to show the next flashcard
  void showNextFlashcard() {
    setState(() {
      currentFlashcardIndex = (currentFlashcardIndex + 1) % flashcards.length;
      showAnswer = false; // Reset to showing the question when moving to the next flashcard
      _controller.reverse();
    });
  }

  // Method to toggle between showing the question and answer when the card is tapped
  void onTapCard() {
    setState(() {
      showAnswer = !showAnswer;
      if (showAnswer) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  // Function to calculate font size based on text length
  double calculateFontSize(String text) {
    if (text.length <= 15) {
      return 24.0;
    } else if (text.length > 15 && text.length <= 25) {
      return 18.0;
    } else {
      return 16.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontFamily: AppFonts.alatsiRegular,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTapCard,
                child: Container(
                  decoration: showAnswer
                      ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.blue, // Set the border color
                      width: 2.0, // Set the border width
                    ),
                  )
                      : null,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final rotation = _frontRotation.value < 90.0
                          ? _frontRotation.value
                          : _backRotation.value;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateY(rotation * 3.1415927 / 180),
                        alignment: Alignment.center,
                        child: Card(
                          color: showAnswer ? Color(0xFFe5f3fd) : Colors.blueAccent,
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (flashcards.isNotEmpty)
                                  ...[
                                    if (flashcards[currentFlashcardIndex][showAnswer ? 'answerImageURL' : 'questionImageURL'] != null &&
                                        flashcards[currentFlashcardIndex][showAnswer ? 'answerImageURL' : 'questionImageURL']!.isNotEmpty)
                                      // CachedNetworkImage(
                                      //   imageUrl: flashcards[currentFlashcardIndex][showAnswer ? 'answerImageURL' : 'questionImageURL']!,
                                      //   errorWidget: (BuildContext context, String url, dynamic error) {
                                      //     return Text('');
                                      //   },
                                      //   height: 200, // Adjust the height as needed
                                      //   width: double.infinity,
                                      //   fit: BoxFit.cover,
                                      //   placeholder: (BuildContext context, String url) {
                                      //     return CircularProgressIndicator(); // Placeholder widget while loading
                                      //   },
                                      //   cacheKey: flashcards[currentFlashcardIndex][showAnswer ? 'answerImageURL' : 'questionImageURL']!,
                                      // ),
                                      Image.network(
                                        flashcards[currentFlashcardIndex][showAnswer ? 'answerImageURL' : 'questionImageURL']!,
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Text('');
                                        },
                                        height: 200, // Adjust the height as needed
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(), // Loading indicator widget
                                            );
                                          }
                                        },
                                      ),

                                    SizedBox(height: 20),
                                    Text(
                                      showAnswer
                                          ? flashcards[currentFlashcardIndex]['answer']!
                                          : flashcards[currentFlashcardIndex]['question']!,
                                      style: TextStyle(
                                        color: showAnswer ? Colors.black : Colors.white,
                                        fontSize: calculateFontSize(showAnswer
                                            ? flashcards[currentFlashcardIndex]['answer']!
                                            : flashcards[currentFlashcardIndex]['question']!),
                                        fontWeight: showAnswer ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                    ),
                                  ]
                                else
                                  Text(
                                    'No Flashcards Available',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton(
                  onPressed: showPreviousFlashcard,
                  child: Icon(CupertinoIcons.left_chevron, size: 40, color: Colors.black87,),
                ),
                Text(
                  '${currentFlashcardIndex + 1}/${flashcards.length}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                CupertinoButton(
                  onPressed: showNextFlashcard,
                  child: Icon(CupertinoIcons.right_chevron, size: 40, color: Colors.black87,),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: shuffleFlashcards,
        child: Icon(CupertinoIcons.shuffle, color:  Colors.orange.shade900, size: 22,),
        backgroundColor: Color(0xFFe5f3fd), // Customize the background color
        elevation: 0, // Add some elevation
        mini: true, // Make it smaller
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Make it circular
        ),
      ),
    );
  }


  // Method to show the previous flashcard
  void showPreviousFlashcard() {
    setState(() {
      currentFlashcardIndex = (currentFlashcardIndex - 1 + flashcards.length) % flashcards.length;
      showAnswer = false; // Reset to showing the question when moving to the previous flashcard
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
