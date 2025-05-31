import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'Pomo_settings.dart';

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  late AndroidInitializationSettings initializationSettingsAndroid;
  late InitializationSettings initializationSettings;
  late SharedPreferences prefs;
  int _pomodorosUntilLongBreak = 4; // Initialize with a default value


  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  String _currentPhase = 'Pomodoro';
  String _notificationSound = 'notification_sound.mp3'; // Placeholder for sound file
  int _completedPomodoros = 0;

  int _pomodoroDuration = 25 * 60; // Default Pomodoro duration in seconds
  int _shortBreakDuration = 5 * 60; // Default short break duration in seconds
  int _longBreakDuration = 15 * 60; // Default short break duration in seconds

  bool _isPaused = false;
  int _pausedSeconds = 0;

  void _startTimer(int duration, String phase) {
    setState(() {
      _isRunning = true;
      _currentPhase = phase;
      _secondsRemaining = duration;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_isPaused) {
          return; // Do nothing if paused
        }
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer!.cancel();
          _isRunning = false;
          _showNotification('Pomodoro Ended', 'Time for a break!');
          _handleTimerCompletion();
        }
      });
    });
  }


  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isPaused = true;
        _pausedSeconds = _secondsRemaining;
      });
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      _startTimer(_pausedSeconds, _currentPhase);
    }
  }

  void _startStopTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer(_pomodoroDuration, 'Pomodoro');
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false; // Reset pause state if timer is stopped
      _secondsRemaining = 0; // Reset seconds remaining to 0
    });
  }

  void _handleTimerCompletion() {
    if (_currentPhase == 'Pomodoro') {
      _completedPomodoros++;
      if (_completedPomodoros % _pomodorosUntilLongBreak == 0) {
        _startTimer(_longBreakDuration, 'Long Break');
      } else {
        _startTimer(_shortBreakDuration, 'Short Break');
      }
    } else if (_currentPhase == 'Short Break' || _currentPhase == 'Long Break') {
      _startTimer(_pomodoroDuration, 'Pomodoro');
    }

    _vibrateDevice(); // Vibrate the device
    _playAlarmSound(); // Play alarm sound
  }


  void _vibrateDevice() async {
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.success); // Vibrate the device
    }
  }

  void _playAlarmSound() async {
    // play audio
    final player = AudioPlayer();
    await player.play(AssetSource('audio/good.mp3'));
  }


  Future<void> _initializeNotifications() async {
    initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(_notificationSound),
      enableVibration: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  Future<void> _loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedPomodoros = prefs.getInt('completed_pomodoros') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    await prefs.setInt('completed_pomodoros', _completedPomodoros);
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    // Define icons for different phases
    IconData phaseIcon = _currentPhase == 'Pomodoro'
        ? Icons.timer_rounded
        : _currentPhase == 'Long Break'
        ? Icons.bedtime_rounded // Change to your desired icon for long breaks
        : Icons.coffee_rounded; // Default icon for short breaks

    Color iconColor = _currentPhase == 'Pomodoro'
        ? Colors.red
        : _currentPhase == 'Long Break'
        ? Colors.indigo // Change to your desired color for long breaks
        : Colors.brown; // Default color for short breaks

    String phaseText = _currentPhase == 'Pomodoro'
        ? 'Pomodoro'
        : _currentPhase == 'Long Break' ? 'Long Break'
        : _currentPhase == 'Short Break' ? 'Short Break' : 'Coffee Break';

    Color iconColorz = _isRunning ? Colors.white : Colors.white;
    Color iconColor2 = _isPaused  ? Colors.white : Colors.white;

    bool _isButtonEnabled = true; // Track the button's enabled/disabled state

    double progress = _secondsRemaining /
        (_currentPhase == 'Pomodoro' ? _pomodoroDuration : _shortBreakDuration);

    // Set background color based on the current phase
    Color backgroundColor = Color(0xFFe5f3fd); // Default background color
    if (_currentPhase == 'Short Break') {
      backgroundColor = Colors.brown; // Change to a different color for short breaks
    } else if (_currentPhase == 'Long Break') {
      backgroundColor = Colors.indigo; // Change to a different color for long breaks
    }

    // // Calculate Pomodoros left until long break
    // int pomodorosUntilLongBreak = 4 - (_completedPomodoros % 4);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
        hintColor: Colors.indigo,
        fontFamily: AppFonts.alatsiRegular,
      ),
      home: Scaffold(
        backgroundColor: backgroundColor, // Set the background color here
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text('Pomodoro', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.bold, fontSize: 28
          ,color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                  ? Colors.white // Change to your desired color for short and long breaks
                  : Colors.black),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                ? Colors.white // Change to your desired color for short and long breaks
                : Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: IconButton(
                onPressed: () {
                  _showResetConfirmationDialog(); // Show confirmation dialog
                },
                icon: Icon(Icons.refresh), // Change the icon to refresh
                tooltip: 'Reset Completed Pomodoros', // Optional tooltip
                color: Colors.red, // Icon color
                iconSize: 20, // Icon size
              ),
            ),
            SizedBox(width: 5),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: IconButton(
                icon: Icon(Icons.help_outline_rounded),
                color: Colors.black,
                iconSize: 20,
                onPressed: () {
                  _showHelpDialog(); // Show help dialog when the help button is clicked
                },
              ),
            ),
            SizedBox(width: 5,),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
              child: IconButton(
                icon: Icon(Icons.settings_rounded, color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
              ? Colors.black87 // Change to your desired color for short and long breaks
              : Colors.black),
                iconSize: 20,
                onPressed: () async {
                  final result = await PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: SettingsScreen(
                      onUpdatePomodorosUntilLongBreak: (value) {
                        setState(() {
                          _pomodorosUntilLongBreak = value;
                        });
                      },
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _pomodoroDuration = result['pomodoroDuration'];
                      _shortBreakDuration = result['shortBreakDuration'];
                      _longBreakDuration = result['longBreakDuration'];
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 10)
          ],
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display icon and text for current phase
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.white, // Background color of the container
                    ),child: Icon(phaseIcon, color: iconColor, size: 20,)),
                    SizedBox(width: 5),
                    Text(
                      'Current phase: $phaseText',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                            ? Colors.white // Change to your desired color for short and long breaks
                            : Colors.black, // Default color for other phases,
                    ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 76, fontWeight: FontWeight.normal,
                    color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                        ? Colors.white // Change to your desired color for short and long breaks
                        : Colors.black),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust the alignment as needed
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _stopTimer : () => _startStopTimer(),
                      icon: Icon(
                        _isRunning ? Icons.stop_circle_rounded : Icons.not_started,
                        color: iconColorz,
                      ),
                      label: Text(
                        _isRunning ? 'Stop' : 'Start',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _isRunning ? Colors.red : Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRunning
                          ? _isPaused
                          ? _resumeTimer
                          : _pauseTimer
                          : null,
                      icon: Icon(_isPaused ? Icons.play_circle: Icons.pause_circle, color: iconColor2,),
                      label: Text(
                        _isPaused ? 'Resume' : 'Pause',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaused ? Colors.green : Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30), // Adjust the horizontal padding as needed
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(4),
                    value: progress,
                    backgroundColor: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                        ? Colors.black // Change to your desired color for short and long breaks
                        : Colors.grey[300], // Default color for other phases
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                          ? Colors.white // Change to your desired color for short and long breaks
                          : Colors.black, // Default color for other phases
                    ),
                    minHeight: 10, // Adjust the height of the progress bar
                    semanticsLabel: 'Loading', // Add a label for accessibility
                  ),
                ),
                  SizedBox(height: 50),
                Text(
                  'Completed pomodoros: $_completedPomodoros',
                  style: TextStyle(fontSize: 20, fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.bold,
                    color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                    ? Colors.white70 // Change to your desired color for short and long breaks
                        : Colors.black.withOpacity(0.6), // Default color for other phases,),
                ),
                ),
SizedBox(height: 5,),
                Text(
                  'Pomodoros until long break: $_pomodorosUntilLongBreak',
                  style: TextStyle(fontSize: 18, fontFamily: AppFonts.alatsiRegular,
                    fontWeight: FontWeight.normal, fontStyle: FontStyle.italic,
                    color: _currentPhase == 'Short Break' || _currentPhase == 'Long Break'
                        ? Colors.white60 // Change to your desired color for short and long breaks
                        : Colors.black.withOpacity(0.5), // Default color for other phases,),
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          title: Text('Reset Completed Pomodoros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          content: Text('Are you sure you want to reset the completed pomodoros?', style: TextStyle(fontSize: 14),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _completedPomodoros = 0;
                });
              },
              child: Text('Reset', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          scrollable: true,
          title: Text('Pomodoro Technique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is Pomodoro?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The Pomodoro Technique is a time management method that uses a timer to break down work into intervals,'
                    ' traditionally 25 minutes in length, separated by short breaks.',
              ),
              SizedBox(height: 16),
              Text(
                'Benefits of Pomodoro:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Increased productivity\n'
                    '- Improved focus\n'
                    '- Better time management\n'
                    '- Reduced procrastination',
              ),
              SizedBox(height: 16),
              Text(
                'How to Use Pomodoro:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Choose a task to work on.\n\n'
                    '2. Set the Pomodoro timer (default: 25 minutes).\n\n'
                    '3. Work on the task until the timer rings.\n\n'
                    '4. Take a short break (default: 5 minutes).\n\n'
                    '5. Repeat steps 1-4 for four cycles.\n\n'
                    '6. After four cycles, take a long break (default: 15 minutes).\n\n'
                    '7. Reset the cycle and start again if needed.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
            ),
          ],
        );
      },
    );
  }



  @override
  void dispose() {
    _timer?.cancel();
    _saveSettings();
    super.dispose();
  }
}
