import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import the package for the progress indicator

class TaskMasterDialog extends StatefulWidget {
  @override
  _TaskMasterDialogState createState() => _TaskMasterDialogState();
}

class _TaskMasterDialogState extends State<TaskMasterDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Task Master\n'
                        '      Badge',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white, // Background color of the container
                  ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.calendar_today,
                        size: 50,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Example 2: Progress indicator
                  SpinKitFoldingCube(
                    color: Colors.white.withOpacity(0.8),
                    size: 50,
                  ),
                  SizedBox(height: 35),
                  Text(
                    'This badge can be obtained\n'
                        '       by finishing 20 tasks',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
