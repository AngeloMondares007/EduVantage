import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/res/fonts.dart';

class AdminLearningToolsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVantage',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: AdminLearningToolsPage(),
    );
  }
}

class AdminLearningToolsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Learning Tools',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: AppFonts.alatsiRegular,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            LearningToolCard(
              toolName: 'Flashcards',
              iconWow: Icon(Icons.flash_on_rounded, size: 50,),
              onPressed: () {
                // Implement flashcards functionality
              },
            ),
            LearningToolCard(
              toolName: 'Recorder',
              iconWow: Icon(Icons.keyboard_voice_rounded, size: 50,),
              onPressed: () {
                // Implement recorder functionality
              },
            ),
            LearningToolCard(
              toolName: 'Notes',
              iconWow: Icon(Icons.lightbulb, size: 50,),
              onPressed: () {
                // Implement notes functionality
              },
            ),

          ],
        ),
      ),
    );
  }
}

class LearningToolCard extends StatelessWidget {
  final String toolName;
  final Icon iconWow;
  final VoidCallback onPressed;

  LearningToolCard({
    required this.toolName,
    required this.iconWow,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      color: CupertinoColors.systemYellow,
      elevation: 2.0,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWow,
              // Icon(Icons.flash_on_rounded, size: 48.0), // You can use different icons
              SizedBox(height: 16.0),
              Text(
                toolName,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.alatsiRegular,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
