import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_vantageAI/feedbackAdmin.dart';

import '../admin_chat/admin_user/UserDetails.dart';

void main() {
  runApp(MaterialApp(
    home: AdminVantage(),
  ));
}

class AdminVantage extends StatefulWidget {
  @override
  _AdminVantageState createState() => _AdminVantageState();
}

class _AdminVantageState extends State<AdminVantage> {
  bool userLogsLoaded = false;
  String selectedTimeRange = 'Active';
  String subheading = 'All Users';
  late List<ChartData> chartData = [];
  String selectedCategory = '';
  int active = 0;
  int inactive = 0;
  int moderate = 0;
  List moderateUserList = [];
  List activeUserList = [];
  List inactiveUserList = [];
  List userList = [];

  @override
  void initState() {
    getUserRecentActivityTimestamp();
    super.initState();
    updateChart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'User Engagement',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
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
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AdminFeedbackScreen(),
                  withNavBar: false,
                );
              },
              icon: Icon(Icons.star_rounded, size: 20, color: Colors.yellow.shade800,),
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
              onPressed: userLogsLoaded ? _saveUsersToPDF : null,
              icon: Icon(Icons.save, size: 20, color: Colors.blue,),
            ),
          ),
          SizedBox(width: 15),
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
                  children: [],
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
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: CupertinoColors.white, // Background color of the container
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Total: ${userList.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Active: $active',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Moderate: $moderate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow.shade700,
                        ),
                      ),
                      Text(
                        'Inactive: $inactive',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 400,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: chartData,
                            onPointTap: (value) {
                              final tappedBarIndex = value.pointIndex;
                              var data = chartData;
                              if (tappedBarIndex! >= 0 && tappedBarIndex < data.length) {
                                switch(value.dataPoints![tappedBarIndex].x) {
                                  case "Active":
                                    _showUsersModal(activeUserList, value.dataPoints![tappedBarIndex].x);
                                    break;
                                  case "Inactive":
                                    _showUsersModal(inactiveUserList, value.dataPoints![tappedBarIndex].x);
                                    break;
                                  case "Moderate":
                                    _showUsersModal(moderateUserList, value.dataPoints![tappedBarIndex].x);
                                    break;
                                }
                              }
                            },
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.value,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              textStyle: TextStyle(color: Colors.black),
                            ),
                            pointColorMapper: (ChartData data, _) {
                              switch (data.category) {
                                case 'Active':
                                  return Colors.green;
                                case 'Moderate':
                                  return Colors.yellow.shade700;
                                case 'Inactive':
                                  return Colors.black;
                                default:
                                  return Colors.black;
                              }
                            },
                          ),
                        ],
                        legend: Legend(isVisible: true),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> getAllUsers() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('User');
    DatabaseEvent dataSnapshot = await usersRef.once();
    List<String> userIds = [];
    if (dataSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> users = dataSnapshot.snapshot.value as Map;
      userIds = users.keys.cast<String>().toList();
    }
    return userIds;
  }

  Future<void> getUserRecentActivityTimestamp() async {
    var users = await getAllUsers();
    log(users.toString());
    List<ChartData> newChartData = [];
    List newUserList = [];
    CollectionReference activityLogsCollection =
    FirebaseFirestore.instance.collection('ActivityLogs');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    int activeCount = 0;
    List activeList = [];
    int moderateCount = 0;
    List moderateList = [];
    int inactiveCount = 0;
    List inactiveList = [];

    try {
      await Future.forEach(users, (id) async {
        var user = await getUser(id.toString());
        newUserList.add(user);
        var activityLogs = await activityLogsCollection
            .where('userId', isEqualTo: id)
            .orderBy("timestamp", descending: true)
            .get();
        if (activityLogs.docs.isNotEmpty) {
          var activityLogsData =
          activityLogs.docs[0].data() as Map<String, dynamic>;
          log('${activityLogsData['timestamp']}');
          dynamic activityTimestamp =
              (activityLogsData['timestamp'] as Timestamp)
                  .toDate()
                  .millisecondsSinceEpoch;
          final timeDifference = currentTime - activityTimestamp;
          if (timeDifference <= Duration(days: 7).inMilliseconds) {
            activeCount++;
            activeList.add(user);
          } else if (timeDifference <= Duration(days: 30).inMilliseconds) {
            moderateCount++;
            moderateList.add(user);
          } else {
            inactiveCount++;
            inactiveList.add(user);
          }
        } else {
          inactiveCount++;
          inactiveList.add(user);
        }
      });
    } catch (e) {
      print("Error fetching recent activity: $e");
    }

    setState(() {
      active = activeCount;
      moderate = moderateCount;
      inactive = inactiveCount;
      activeUserList = activeList;
      moderateUserList = moderateList;
      inactiveUserList = inactiveList;
      newChartData = [
        ChartData("Active", active),
        ChartData("Moderate", moderate),
        ChartData("Inactive", inactive)
      ];
      chartData = newChartData;
      userList = newUserList;
    });
    userLogsLoaded = true;
  }

  void updateChart() async{
    setState(()  {
      chartData = [
        ChartData("Active", active),
        ChartData("Moderate", moderate),
        ChartData("Inactive", inactive)
      ];
    });
  }

  void _showUsersModal(List users, String label) async {
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
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          content: SingleChildScrollView(
            child: SizedBox (
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: users.map((user) {
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            _navigateToUserProfile(user[0]);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black87)],
                              border: Border.all(color: Colors.black87),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: user[2],
                              placeholder: (context, url) => Icon(CupertinoIcons.person, color: Colors.white, size: 20,),
                              errorWidget: (context, url, error) => Icon(CupertinoIcons.person, color: Colors.white, size: 20,),
                              imageBuilder: (context, imageProvider) => ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: imageProvider,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          user[1],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Engagement: ${label}"),
                          ],
                        ),
                      ),
                    );
                  }
                  ).toList(),
                )
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

  Future<List> getUser(String userUID) async {
    try {

      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .ref('User')
          .child(userUID)
          .once();
      List user = [];
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map;
        user.add(userUID);
        user.add(userData['userName']);
        user.add(userData['profile']);
        user.add(userData['studentNumber']);
        user.add(userData['department']);
        user.add(userData['email']);
        return user;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return [];
    }
  }

  void _navigateToUserProfile(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AdminUserDetails(userId: userId),
      withNavBar: false,
    );
  }

  Future<void> _saveUsersToPDF() async {
    final pdf = pw.Document();

    // Add title to the PDF
    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            'User Engagement Report',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Paragraph(text: 'Generated on: ${DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now())}'),
        pw.Paragraph(text: 'Total Users: ${userList.length}'),
        // pw.Paragraph(text: 'Active Users: $active'),
        // pw.Paragraph(text: 'Moderate Users: $moderate'),
        // pw.Paragraph(text: 'Inactive Users: $inactive'),
        pw.Paragraph(text: 'Engagement Breakdown:'),
        pw.Table.fromTextArray(context: context, data: [
          ['Category', 'Count'],
          ['Active', '$active'],
          ['Moderate', '$moderate'],
          ['Inactive', '$inactive'],
        ]),
        pw.Header(level: 1, child: pw.Text('User Details',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Table.fromTextArray(context: context, data: [
          ['Student Number', 'Name', 'Email', 'Department'],
          ...userList.map((user) => [user[3], user[1], user[5], user[4]]).toList(),
        ]),
      ],
    ));

    // Let the user pick a file location
    String? outputPath = await FilePicker.platform.getDirectoryPath();
    if (outputPath != null) {
      // Construct the file path with the selected directory and file name
      String filePath = '$outputPath/User Engagement Report.pdf';
      File file = File(filePath);
      if (file.existsSync()) {
        // If the file already exists, ask the user whether to overwrite or save both
        bool? saveBoth = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text('File Exists'),
              content: Text(
                  'A file with the name User Engagement Report.pdf already exists. Do you want to overwrite it or save both?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(
                        false); // Return false for overwrite
                    await file.writeAsBytes(await pdf.save());
                    print('PDF saved to: $filePath');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          title: Text('PDF Saved'),
                          content: Text('User Engagement Report was saved at $filePath'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Optionally add more actions after closing the dialog
                              },
                              child: Text('OK', style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppFonts.alatsiRegular)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Overwrite', style: TextStyle(
                      color: Colors.red, fontFamily: AppFonts.alatsiRegular)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(
                        true); // Return true for save both
                    int fileNumber = 1;
                    while (file.existsSync()) {
                      filePath = '$outputPath/User Engagement Report ($fileNumber).pdf';
                      file = File(filePath);
                      fileNumber++;
                    }
                    await file.writeAsBytes(await pdf.save());
                    print('PDF saved to: $filePath');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          title: Text('PDF Saved'),
                          content: Text('User Engagement Report was saved at $filePath'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Optionally add more actions after closing the dialog
                              },
                              child: Text('OK', style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppFonts.alatsiRegular)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Save Both', style: TextStyle(
                      color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
                ),
              ],
            );
          },
        );

        if (saveBoth == null) {
          print('User cancelled saving the PDF');
        }
      } else {
        // Write the PDF to the file
        await file.writeAsBytes(await pdf.save());
        print('PDF saved to: $filePath');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text('PDF Saved'),
              content: Text('User Engagement Report was saved at $filePath'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Optionally add more actions after closing the dialog
                  },
                  child: Text('OK', style: TextStyle(
                      color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

class ChartData {
  final String category;
  final num value;

  ChartData(this.category, this.value);
}