import 'package:flutter/material.dart';
import 'package:tech_media/res/fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> flashcards = [
    Flashcard(
      question: "It is a UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.",
      answer:
      "Flutter",
    ),
    Flashcard(
      question: "It is the programming language used for developing apps in Flutter.",
      answer:
      "Dart",
    ),
    Flashcard(
      question: "HTML stands for?",
      answer:
      "Hypertext Markup Language",
    ),
    Flashcard(
      question: "Who invented WWW (World Wide Web?)",
      answer:
      "Tim-Berners Lee (1989)",
    ),
    Flashcard(
      question: "3 + 2",
      answer:
      "5",
    ),
    // Add more flashcards as needed
  ];

  int currentIndex = 0;
  bool showAnswer = false;

  void toggleCard() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void showNextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % flashcards.length;
      showAnswer = false; // Reset to show the question by default
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleCard, // Toggle the card on tap
      child: Scaffold(
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
        backgroundColor: Color(0xFFe5f3fd),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: showAnswer ? Colors.black : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                color: Color(0xFF64B5F6), // Change the color
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: 400, // Increase the width
                  height: 300, // Increase the height
                  child: Center(
                    child: Text(
                      showAnswer
                          ? flashcards[currentIndex].answer
                          : flashcards[currentIndex].question,
                      style: TextStyle(
                        fontSize: 24, // Adjust the font size
                        color: showAnswer ? Colors.black : Colors.white, // Change the text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 150),
              ElevatedButton(
                onPressed: showNextCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.7), // Change button color
                  minimumSize: Size(10, 50), // Set button size
                ),
                child: Text(
                  'Next Question',
                  style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 20, // Change the button text font size
                    color: Colors.white, // Change the button text color
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}
