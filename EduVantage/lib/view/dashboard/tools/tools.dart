import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/FlashcardMM.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/PDF%20Scanner/Pdf.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Pomodoro/PomodorMainMenu.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Recorder/RecordingScreen.dart';
import 'package:confetti/confetti.dart';
import '../LearningTools/LT-Functions/Notes/NotesScreen.dart';
import '../vantageAI/vantage.dart';

class LearningToolsScreen extends StatelessWidget {
  final String userUID;
  LearningToolsScreen({required this.userUID});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVantage',
      theme: ThemeData(
        colorScheme:
        ColorScheme.fromSeed(
            seedColor: Colors.blue,
            background: Colors.white,
            error: Colors.red,
            onTertiary: Colors.orange
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: LearningToolsPage(userUID: userUID),
    );
  }
}

class LearningToolsPage extends StatefulWidget {
  final String userUID;
  LearningToolsPage({required this.userUID});

  @override
  _LearningToolsPageState createState() => _LearningToolsPageState();
}

class _LearningToolsPageState extends State<LearningToolsPage> {
  late ConfettiController _confettiController;
  bool isPomodoroLocked = false;
  bool isDocumentScannerLocked = false;
  bool isRefreshing = false; // Track the refreshing state
  int completedTasksCount = 0; // Initialize completedTasksCount
  int completedDocumentTasksCount = 0; // Initialize completed tasks count for Document Scanner



  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    checkTasksCompletion();
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  Future<void> checkTasksCompletion() async {
    try {
      // Simulate fetching data
      await Future.delayed(Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userUID', isEqualTo: widget.userUID)
          .get();

      completedTasksCount = querySnapshot.docs
          .where((doc) =>
      doc.data() != null &&
          (doc.data() as Map<String, dynamic>).containsKey('isDone') &&
          (doc.data() as Map<String, dynamic>)['isDone'] == true)
          .length;

      setState(() {
        isPomodoroLocked = completedTasksCount < 10;
        isDocumentScannerLocked = completedTasksCount < 15; // Adjust the count as needed
      });

    } catch (error) {
      print('Error fetching tasks data: $error');
      // Handle error accordingly
    }
  }

  Future<void> handleRefresh() async {
    setState(() {
      isRefreshing = true; // Set refreshing state to true
    });

    await checkTasksCompletion(); // Refresh data

    setState(() {
      isRefreshing = false; // Set refreshing state back to false
    });
  }

  void navigateToVantage(BuildContext context, {required bool showBackButton}) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: Vantage(userUID: widget.userUID),
      withNavBar: false,
    );
  }

  void navigateToPomodoro(BuildContext context) {
    if (!isPomodoroLocked) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: PomodoroScreen(),
        withNavBar: false,
      );
      // Show confetti animation
      _confettiController.play();

    } else {
      int remainingTasks = 10 - completedTasksCount; // Calculate remaining tasks
      // Show a dialog explaining why Pomodoro is locked
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.timer_rounded, color: Colors.indigo), // Lock icon
                SizedBox(width: 8), // Space between icon and text
                Text(
                  'Pomodoro is Locked',
                  style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          content: Text(
              'Pomodoro is locked until 10 tasks are completed\n\n'
                  'Finish $remainingTasks more tasks to unlock this feature',
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void navigateToDocumentScanner(BuildContext context) {
    if (!isDocumentScannerLocked) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DocumentScannerScreen(),
        withNavBar: false,
      );
      // Show confetti animation
      _confettiController.play();
    }
    else {
      int remainingTasks = 15 - completedTasksCount; // Calculate remaining tasks
      // Show a dialog explaining why Pomodoro is locked
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.document_scanner_rounded, color: Colors.pink), // Lock icon
                SizedBox(width: 8), // Space between icon and text
                FittedBox(
                  child: Text(
                    'Scanner is Locked',
                    style: TextStyle(
                      fontFamily: AppFonts.alatsiRegular,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Document Scanner is locked until 15 tasks are completed\n\n'
                  'Finish $remainingTasks more tasks to unlock this feature',
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    checkTasksCompletion(); // Check tasks completion when the widget is built
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Learning Tools',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: AppFonts.alatsiRegular, // Use the desired font
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              LearningToolCard(
                elevation: 0,
                toolName: 'Notes',
                iconWow: Icon(
                  Icons.edit,
                  size: 50,
                  color: Colors.blue,
                ),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: NotesScreen(),
                    withNavBar: false,
                  );
                },
                backgroundColor: Colors.white,
                textColor: Colors.blue,
                locked: false,
              ),
              LearningToolCard(
                elevation: 0,
                toolName: 'Recorder',
                iconWow: Icon(
                  Icons.keyboard_voice_rounded,
                  size: 50,
                  color: Colors.red,
                ),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: RecorderScreen(),
                    withNavBar: false,
                  );
                },
                backgroundColor: Colors.white,
                textColor: Colors.red,
                locked: false,
              ),
              LearningToolCard(
                elevation: 0,
                toolName: 'Flashcards',
                iconWow: Icon(Icons.flash_on_rounded, size: 50, color: Colors.yellow.shade800),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: FlashcardMainMenu(
                      userUID: widget.userUID,
                    ),
                    withNavBar: false,
                  );
                },
                backgroundColor: Colors.white,
                textColor: Colors.yellow.shade800,
                locked: false,
              ),
              LearningToolCard(
                elevation: 0,
                toolName: 'Statistics',
                iconWow: Icon(
                  Icons.area_chart_rounded,
                  size: 48,
                  color: Colors.green,
                ),
                onPressed: () {
                  navigateToVantage(context, showBackButton: true);
                },
                backgroundColor: Colors.white,
                textColor: Colors.green,
                locked: false,
              ),
              LearningToolCard(
                elevation: 0,
                toolName: 'Pomodoro',
                iconWow: Icon(
                  Icons.timer_rounded,
                  size: 48,
                  color: isPomodoroLocked ? Colors.black54 : Colors.indigo,
                ),
                onPressed: () {
                  navigateToPomodoro(context);
                },
                backgroundColor: isPomodoroLocked ? Colors.grey.shade300 : Colors.white,
                textColor: isPomodoroLocked ? Colors.black54 : Colors.indigo,
                locked: isPomodoroLocked,
              ),
              LearningToolCard(
                elevation: 0,
                toolName: 'Document Scanner',
                iconWow: Icon(
                  Icons.document_scanner_rounded,
                  size: 42,
                  color: isDocumentScannerLocked ? Colors.black54 : Colors.pink,
                ),
                onPressed: ()
                {navigateToDocumentScanner(context);
                },
                backgroundColor: isDocumentScannerLocked ? Colors.grey.shade300 : Colors.white,
                textColor: isDocumentScannerLocked ? Colors.black54 : Colors.pink,
                locked: isDocumentScannerLocked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningToolCard extends StatelessWidget {
  final String toolName;
  final Icon iconWow;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final bool locked;

  LearningToolCard({
    required this.toolName,
    required this.iconWow,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.elevation = 1.0,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: backgroundColor,
      elevation: elevation,
      child: InkWell(
        onTap: locked ? onPressed : onPressed, // Disable onTap if locked
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  iconWow,
                  if (locked)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container
                        (decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white.withOpacity(0.9), // Background color of the container
                      ),
                        child: Icon(
                          Icons.lock,
                          size: 24,
                          color: Colors.red,
                        ),
                        width: 50,
                        height: 50,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.0), // Space between icons and text
              Text(
                toolName,
                style: TextStyle(
                  fontFamily: AppFonts.alatsiRegular,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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
