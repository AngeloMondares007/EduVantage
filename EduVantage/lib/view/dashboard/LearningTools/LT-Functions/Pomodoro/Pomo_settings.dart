import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_media/res/fonts.dart';

class TimePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String) onChanged;

  const TimePicker({
    Key? key,
    required this.controller,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*$')), // Only allow digits with minimum 1
              FilteringTextInputFormatter.digitsOnly, // Only allow digits
              LengthLimitingTextInputFormatter(3), // Limit input to 4 characters (maximum 1500)
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Text(label), // Display the label for the time picker
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {

  final Function(int) onUpdatePomodorosUntilLongBreak;

  const SettingsScreen({Key? key, required this.onUpdatePomodorosUntilLongBreak}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _pomodoroController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;
  late TextEditingController _pomodorosUntilLongBreakController; // New controller

  @override
  void initState() {
    super.initState();
    _pomodoroController = TextEditingController();
    _shortBreakController = TextEditingController();
    _longBreakController = TextEditingController();
    _pomodorosUntilLongBreakController = TextEditingController(); // Initialize controller
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _pomodoroController.text = ((prefs.getInt('pomodoro_duration') ?? 25 * 60) ~/ 60).toString();
      _shortBreakController.text = ((prefs.getInt('short_break_duration') ?? 5 * 60) ~/ 60).toString();
      _longBreakController.text = ((prefs.getInt('long_break_duration') ?? 15 * 60) ~/ 60).toString();
      _pomodorosUntilLongBreakController.text = (prefs.getInt('pomodoros_until_long_break') ?? 4).toString(); // Default value
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoro_duration', int.parse(_pomodoroController.text) * 60);
    await prefs.setInt('short_break_duration', int.parse(_shortBreakController.text) * 60);
    await prefs.setInt('long_break_duration', int.parse(_longBreakController.text) * 60);
    await prefs.setInt('pomodoros_until_long_break', int.parse(_pomodorosUntilLongBreakController.text)); // Save value
    widget.onUpdatePomodorosUntilLongBreak(int.parse(_pomodorosUntilLongBreakController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Pomodoro Settings', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.bold, fontSize: 28),),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimePicker(
              label: 'Pomodoro Duration (minutes) \n'
                     'Default: 25 minutes',
              controller: _pomodoroController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            TimePicker(
              label: 'Short Break Duration (minutes) \n'
                      'Default: 5 minutes',
              controller: _shortBreakController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            TimePicker(
              label: 'Long Break Duration (minutes) \n'
                     'Default: 15 minutes',
              controller: _longBreakController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            TimePicker(
              label: 'Pomodoros Until Long Break \n'
                     'Default: 4',
              controller: _pomodorosUntilLongBreakController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 50),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSettings();
                  Navigator.pop(context, {
                    'pomodoroDuration': int.parse(_pomodoroController.text) * 60,
                    'shortBreakDuration': int.parse(_shortBreakController.text) * 60,
                    'longBreakDuration': int.parse(_longBreakController.text) * 60,
                    'pomodorosUntilLongBreak': int.parse(_pomodorosUntilLongBreakController.text),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Save Settings',
                  style: TextStyle(
                    fontFamily: AppFonts.alatsiRegular,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    _pomodorosUntilLongBreakController.dispose(); // Dispose controller
    super.dispose();
  }
}
