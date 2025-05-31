import 'dart:math'; // Import the math library for randomization
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/vantageAI/Task%20Completion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// void main() {
//   runApp(MaterialApp(
//     home: Vantage(),
//   ));
// }

class Vantage extends StatefulWidget {
  final String userUID;
  Vantage({required this.userUID});
  @override
  _VantageState createState() => _VantageState(userUID: userUID);
}

class _VantageState extends State<Vantage> {
  String selectedTimeRange = 'Weekly'; // Default selected time range
  String subheading = 'Weekly'; // Default subheading
  final String userUID;
  _VantageState({required this.userUID});
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> completedTasks = []; // Separate list for completed tasks
  List<String> encouragementMessages = [
    "You're doing great!",
    "Keep up the good work!",
    "Finish tasks to get rewards",
    "You're making progress!",
    "Awesome job!",
    "Stay focused and motivated!",
    "Finish 50 tasks to unlock POMODORO",
    "You're on the right track!",
    "Believe in yourself!",
    "Keep pushing forward!",
    "You've got this!",
    "Every small step counts!",
    "Don't give up, you're closer than you think!",
    "Embrace the challenges, they make you stronger!",
    "Success is just around the corner!",
  ];
  @override
  void initState() {
    super.initState();
    fetchTasksData();
  }

  void fetchTasksData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Tasks').where("userUID", isEqualTo: userUID).get();
      setState(() {
        tasks = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        // Update completed tasks list based on 'isDone' status
        completedTasks = tasks.where((task) => task['isDone'] == true).toList();
      });
    } catch (error) {
      print('Error fetching tasks data: $error');
    }
  }

  // Calculate total completed tasks from completedTasks list
  int getTotalCompletedTasks() {
    return completedTasks.length;
  }

  @override
  Widget build(BuildContext context) {
    int totalTasksCompleted = tasks.where((task) => task['isDone'] == true).length;
    String randomEncouragement = encouragementMessages[Random().nextInt(encouragementMessages.length)];
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Statistics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            // fontFamily: AppFonts.alatsiRegular, // Use the desired font
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, // Change the color of the back button
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: CupertinoColors.white, // Background color of the container
              ),
              child: IconButton(
                icon: Icon(Icons.stacked_bar_chart),
                iconSize: 30,
                color: Colors.blueAccent,
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: TaskCompletion(tasks: tasks,),
                    withNavBar: false,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 10,)
          // Add more buttons as needed
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.access_time_filled_rounded),
                    //   iconSize: 30,
                    //   color: Colors.pinkAccent, // Replace with your desired icon
                    //   onPressed: () {
                    //     PersistentNavBarNavigator.pushNewScreen(
                    //       context,
                    //       screen: AppUsageScreen(userUID: userUID,),
                    //       withNavBar: false,
                    //     );
                    //   },
                    // )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  subheading,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        randomEncouragement,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Total Tasks Completed: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$totalTasksCompleted', // Apply fontWeight directly to the value
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Make only the value bold
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 100),
              Container(
                height: 300,
                margin: EdgeInsets.all(16),
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    interval: 1,
                  ),
                  // tooltipBehavior: TooltipBehavior(enable: true), // Enable tooltip
                  zoomPanBehavior: ZoomPanBehavior(
                    enableDoubleTapZooming: true,
                    enablePinching: true,
                    enablePanning: true,
                  ),
                  series: <CartesianSeries>[ // Use CartesianSeries instead of ChartSeries
                    ColumnSeries<ChartData, String>(
                      color: Colors.green,
                      dataSource: getData(selectedTimeRange, tasks, userUID),
                      xValueMapper: (ChartData data, _) => data.day,
                      yValueMapper: (ChartData data, _) => data.value1,
                      onPointTap: (value) {
                        final tappedBarIndex = value.pointIndex;
                        var data = getData(selectedTimeRange, tasks, userUID);
                        if (tappedBarIndex! >= 0 && tappedBarIndex < data.length) {
                          final tappedBarData = data.toList()[tappedBarIndex].task;
                          _showTaskModal(tappedBarData, value.dataPoints![tappedBarIndex].x);
                        }
                      },
                    ),
                  ],
                  // Remove isTransposed property, as ColumnSeries already creates a vertical bar graph
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RoundedButton(
                    label: 'Weekly',
                    isActive: selectedTimeRange == 'Weekly',
                    onPressed: () {
                      updateChart('Weekly');
                    },
                  ),
                  RoundedButton(
                    label: 'Monthly',
                    isActive: selectedTimeRange == 'Monthly',
                    onPressed: () {
                      updateChart('Monthly');
                    },
                  ),
                  RoundedButton(
                    label: 'Semestral',
                    isActive: selectedTimeRange == 'Semestral',
                    onPressed: () {
                      updateChart('Semestral');
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

  void _showTaskModal(List<Map<String, dynamic>> tasks, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
          backgroundColor: Color(0xFFe5f3fd),
          elevation: 0,
          title: Text(label),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tasks.map((task) =>
                  Card(
                      margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                      color: Colors.green,
                      elevation: 0,
                      child: Padding (
                        padding: EdgeInsetsDirectional.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['subjectName'], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                            Text(task['description'], style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),),
                            Text(DateFormat("MMM d, y").format((task['date'] as Timestamp).toDate()), style: TextStyle(color: Colors.white60, fontSize: 12))
                          ],
                        ),
                      )
                  )
              ).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
            ),
          ],
        );
      },
    );
  }

  void updateChart(String timeRange) {
    setState(() {
      selectedTimeRange = timeRange;
      switch (timeRange) {
        case 'Weekly':
          subheading = 'Weekly';
          break;
        case 'Monthly':
          subheading = 'Monthly';
          break;
        case 'Semestral':
          subheading = 'Semestral';
          break;
      }
    });
  }

  List<ChartData> getData(String timeRange, List<Map<String, dynamic>> tasks, String userUID) {
    List<ChartData> chartData = [];

    switch (timeRange) {
      case 'Weekly':
        chartData = getDataForTimeRange('week', tasks, userUID);
        break;
      case 'Monthly':
        chartData = getDataForTimeRange('month', tasks, userUID);
        break;
      case 'Semestral':
        chartData = getDataForTimeRange('semester', tasks, userUID);
        break;
      default:
        chartData = [];
        break;
    }
    return chartData;
  }

  List<ChartData> getDataForTimeRange(String timeRange, List<Map<String, dynamic>> tasks, String userUID) {
    List<ChartData> chartData = [];

    try {
      List<Map<String, dynamic>> filteredTasks = tasks.where((el) {
        return el['isDone'] ?? false;
      }).toList();
      filteredTasks.sort((a, b) {
        return (a['date'] as Timestamp).compareTo(b['date'] as Timestamp);
      });

      filteredTasks.forEach((task) {
        DateTime completionDate = (task['date'] as Timestamp).toDate();
        switch (timeRange) {
          case 'week':
            String weekLabel = getWeekLabel(completionDate);
            _updateChartData(chartData, weekLabel, task);
            break;
          case 'month':
            String monthLabel = DateFormat("MMMM").format(completionDate).toString();
            _updateChartData(chartData, monthLabel, task);
            break;
          case 'semester':
            int month = completionDate.month;
            String semesterLabel = month <= 6 ? 'Semester 1' : 'Semester 2';
            _updateChartData(chartData, semesterLabel, task);
            break;
        }
      });
    } catch (error) {
      print('Error fetching data: $error');
    }

    return chartData;
  }

  String getWeekLabel(DateTime date) {
    // Calculate the week's start date (Sunday) and end date (Saturday)
    DateTime weekStart = date.subtract(Duration(days: date.weekday));
    DateTime weekEnd = weekStart.add(Duration(days: 6));

    // Format the week label
    String weekLabel =
        ' ${DateFormat("M/d").format(weekStart)} - ${DateFormat("M/d").format(weekEnd)}';
    return weekLabel;
  }

  void _updateChartData(List<ChartData> chartData, String label, Map<String, dynamic> task) {
    ChartData? existingData = chartData.firstWhere(
          (data) => data.day == label,
      orElse: () => ChartData('', 0, []),
    );

    if (existingData.day == label) {
      setState(() {
        existingData.value1++;
        existingData.task.add(task);
      });
    } else {
      setState(() {
        chartData.add(ChartData(label, 1, [task]));
      });
    }
  }



}

class ChartData {
  final String day;
  int value1;
  List<Map<String, dynamic>> task;

  ChartData(this.day, this.value1, this.task);
}

class RoundedButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  RoundedButton({required this.label, this.isActive = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isActive ? Colors.green : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.alatsiRegular,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}

