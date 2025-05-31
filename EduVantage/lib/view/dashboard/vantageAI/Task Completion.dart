import 'dart:developer';
import 'dart:math' as mathe; // Import the math library for randomization
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../res/fonts.dart';

class TaskCompletion extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  TaskCompletion({required this.tasks});
  @override
  _TaskCompletionState createState() => _TaskCompletionState(tasks: tasks);
}

class _TaskCompletionState extends State<TaskCompletion> {
  final List<Map<String, dynamic>> tasks;
  _TaskCompletionState({required this.tasks});
  List<ChartData> data = [];
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
    data = getData();
  }

  List<ChartData> getData() {
    List<Map<String, dynamic>> taskTypes = [];
    tasks.forEach((task) {
      var taskType = task['taskType'];
      String status = "";
      var existingTaskType = taskTypes.firstWhere((type) => type['taskType'] == taskType, orElse: () => {});
      if (existingTaskType.isNotEmpty) {
        if (task['isDone'] == null) {
          status = "pending";
        } else if (task['completionDate'] != null && task['date'].toDate().isAfter(task['completionDate'].toDate())) {
          status = "completed";
        } else {
          status = "overdue";
        }
        switch(status) {
          case "pending":
            existingTaskType['pending'] = (existingTaskType['pending'] ?? 0) + 1;
            existingTaskType['pendingTask'].add(task);
            break;
          case "completed":
            existingTaskType['completed'] = (existingTaskType['completed'] ?? 0) + 1;
            existingTaskType['completedTask'].add(task);
            break;
          case "overdue":
            existingTaskType['overdue'] = (existingTaskType['overdue'] ?? 0) + 1;
            existingTaskType['overdueTask'].add(task);
            break;
        }
      } else {
        List<Map<String, dynamic>> emptyPendingTask = [];
        List<Map<String, dynamic>> emptyCompletedTask = [];
        List<Map<String, dynamic>> emptyOverdueTask = [];
        var statusCounts = {
          'pending': task['isDone'] == null ? 1 : 0,
          'pendingTask': task['isDone'] == null ? [task] : emptyPendingTask,
          'completed': task['completionDate'] != null && task['date'].toDate().isAfter(task['completionDate'].toDate()) ? 1 : 0,
          'completedTask': task['completionDate'] != null && task['date'].toDate().isAfter(task['completionDate'].toDate()) ? [task] : emptyCompletedTask,
          'overdue': task['completionDate'] != null && task['date'].toDate().isBefore(task['completionDate'].toDate()) ? 1 : 0,
          'overdueTask': task['completionDate'] != null && task['date'].toDate().isBefore(task['completionDate'].toDate()) ? [task] : emptyOverdueTask,
        };
        taskTypes.add({'taskType': taskType, ...statusCounts});
      }
    });

    List<ChartData> chartDataList = [];

    taskTypes.forEach((type) {
      String taskTypeName = type['taskType'];
      int pending = type['pending'] ?? 0;
      List<Map<String, dynamic>> pendingTask = type['pendingTask'] ?? [];
      int completed = type['completed'] ?? 0;
      List<Map<String, dynamic>> completedTask = type['completedTask'] ?? [];
      int overdue = type['overdue'] ?? 0;
      List<Map<String, dynamic>> overdueTask = type['overdueTask'] ?? [];
      chartDataList.add(ChartData(taskTypeName, pending, pendingTask, completed, completedTask, overdue, overdueTask));
    });
    return chartDataList;
  }

  void _showTaskModal(List<Map<String, dynamic>> tasks, String label, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          elevation: 0,
          backgroundColor: Color(0xFFe5f3fd),
          insetPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 100),
          title: Text(label),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tasks.map((task) =>
                  Card(
                      margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                      color: color,
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

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;
    int totalPending = data.fold(0, (sum, chartData) => sum + (chartData.value1 ?? 0).toInt());
    int totalCompleted = data.fold(0, (sum, chartData) => sum + (chartData.value2 ?? 0).toInt());
    int totalOverdue = data.fold(0, (sum, chartData) => sum + (chartData.value3 ?? 0).toInt());
    String randomEncouragement = encouragementMessages[mathe.Random().nextInt(encouragementMessages.length)];

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
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Task Completion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              SizedBox(height: 130),
              SizedBox(
                width: 600,
                height: 350,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                  ),
                  zoomPanBehavior: ZoomPanBehavior(
                    enableDoubleTapZooming: true,
                    enablePinching: true,
                    enablePanning: true,
                  ),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    shouldAlwaysShow: true,
                    lineType: TrackballLineType.vertical,
                  ),
                  primaryXAxis: CategoryAxis(
                    labelStyle: TextStyle(
                      fontSize: 10, // Adjust the font size as needed
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    minimum: 0,
                    maximum: 10,
                    interval: 1,
                  ),
                  series: <CartesianSeries>[
                    StackedColumnSeries<ChartData, String>(
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(color: Colors.white70),
                      ),
                      dataSource: data,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value1,
                      name: 'Pending',
                      color: Colors.blue,
                      onPointTap: (value) {
                        final tappedBarIndex = value.pointIndex;
                        log(value.dataPoints![tappedBarIndex!].y.toString());
                        var data = getData();
                        if (tappedBarIndex >= 0 && tappedBarIndex < data.length) {
                          final tappedBarData = data.toList()[tappedBarIndex].value1Task;
                          _showTaskModal(tappedBarData, value.dataPoints![tappedBarIndex].x, Colors.blue);
                        }
                      },
                    ),
                    StackedColumnSeries<ChartData, String>(
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(color: Colors.white70),
                      ),
                      dataSource: data,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value2,
                      name: 'Completed',
                      color: Colors.green,
                      onPointTap: (value) {
                        final tappedBarIndex = value.pointIndex;
                        log(value.dataPoints![tappedBarIndex!].y.toString());
                        var data = getData();
                        if (tappedBarIndex >= 0 && tappedBarIndex < data.length) {
                          final tappedBarData = data.toList()[tappedBarIndex].value2Task;
                          _showTaskModal(tappedBarData, value.dataPoints![tappedBarIndex].x, Colors.green);
                        }
                      },
                    ),
                    StackedColumnSeries<ChartData, String>(
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(color: Colors.white70),
                      ),
                      dataSource: data,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value3,
                      name: 'Overdue',
                      color: Colors.red,
                      onPointTap: (value) {
                        final tappedBarIndex = value.pointIndex;
                        log(value.dataPoints![tappedBarIndex!].y.toString());
                        var data = getData();
                        if (tappedBarIndex >= 0 && tappedBarIndex < data.length) {
                          final tappedBarData = data.toList()[tappedBarIndex].value3Task;
                          _showTaskModal(tappedBarData, value.dataPoints![tappedBarIndex].x, Colors.red);
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Total status section
              SizedBox(height: 20),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Total Tasks: $totalTasks',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Total Pending: $totalPending',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Total Completed: $totalCompleted',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Total Overdue: $totalOverdue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

}

class ChartData {
  final String category;
  final num value1;
  List<Map<String, dynamic>> value1Task;
  final num value2;
  List<Map<String, dynamic>> value2Task;
  final num value3;
  List<Map<String, dynamic>> value3Task;

  ChartData(this.category, this.value1, this.value1Task, this.value2, this.value2Task, this.value3, this.value3Task);
}
