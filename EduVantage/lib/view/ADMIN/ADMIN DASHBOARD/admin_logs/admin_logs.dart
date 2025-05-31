import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../admin_chat/admin_user/UserDetails.dart';
import 'package:tech_media/res/fonts.dart';

class ActivityLog {
  final String date;
  final int count;

  ActivityLog({
    required this.date,
    required this.count,
  });

  factory ActivityLog.fromFirestore(Map<String, dynamic> json) {
    return ActivityLog(
      date: DateFormat("MMM d").format((json['timestamp'] as Timestamp).toDate()),
      count: 1,
    );
  }
}

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({Key? key}) : super(key: key);

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  final CollectionReference activityLogsCollection =
  FirebaseFirestore.instance.collection('ActivityLogs');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<ActivityLog> activityLogs = [];

  @override
  void initState() {
    super.initState();
    fetchActivityLogs();
  }

  Future<void> fetchActivityLogs() async {
    QuerySnapshot querySnapshot = await activityLogsCollection
        .where("timestamp",
        isGreaterThan: Timestamp.fromDate(DateTime.now()
            .subtract(const Duration(days: 10)))).orderBy("timestamp")
        .get();

    Map<DateTime, int> activityCountMap = {};
    querySnapshot.docs.forEach((doc) {
      var timestamp = (doc['timestamp'] as Timestamp).toDate();
      var date = DateTime(timestamp.year, timestamp.month, timestamp.day);
      activityCountMap[date] = (activityCountMap[date] ?? 0) + 1;
    });

    List<ActivityLog> logs = [];
    activityCountMap.forEach((date, count) {
      logs.add(ActivityLog(
        date: DateFormat("MMM d").format(date),
        count: count,
      ));
    });
    setState(() {
      activityLogs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: PreferredSize(
        child: getAppBar(),
        preferredSize: Size.fromHeight(60),
      ),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFFe5f3fd),
      title: Text(
        "User Activity",
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 26,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.alatsiRegular,
        ),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 10),
            // Display recent activity logs here
            // Example:
            // activityLogs != null
            //     ? Column(
            //         children: activityLogs.map((log) {
            //           return ListTile(
            //             title: Text(log.activity),
            //             subtitle: Text(log.userId),
            //             trailing: Text(log.timestamp.toString()),
            //           );
            //         }).toList(),
            //       )
            //     : CircularProgressIndicator(),
            // SizedBox(height: 20),
            Text(
              "Activity Trend",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: buildActivityChart(FirebaseFirestore.instance.collection('ActivityLogs')),
            ),
            SizedBox(height: 20),
            Text(
              "Recent Activity Log",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: activityLogsCollection
                    .orderBy("timestamp", descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No logs found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black45)),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                      return FutureBuilder<DatabaseEvent>(
                        future: FirebaseDatabase.instance
                            .ref('User')
                            .child(data['userId'])
                            .once(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          Map<String, dynamic> user = Map<String, dynamic>.from(userSnapshot.data?.snapshot.value as Map);
                          Timestamp timestamp =
                              data['timestamp'] ?? Timestamp.now();
                          return ActivityCard(
                            title: data['title'],
                            message: data['activity'],
                            timestamp: timestamp,
                            imageUrl: user['profile'] ?? '',
                            userUID: user['uid'] ?? '',
                            onPressed: () async {
                              FirebaseAuth auth = FirebaseAuth.instance;
                              User? user = auth.currentUser;
                              log(user!.providerData.toString());
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            // Container(
            //   height: 200,
            //   child: buildUserStatisticsTable(),
            // ),
            // Add more sections/widgets as needed
          ],
        ),
      ),
    );
  }

  Widget buildActivityChart(CollectionReference<Map<String, dynamic>> collectionReference) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collectionReference.orderBy("timestamp").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<ActivityLog> activityLogs = snapshot.data!.docs
              .map((doc) => ActivityLog.fromFirestore(doc.data()))
              .toList();
          var chartData = <ChartData>[];
          activityLogs.forEach((log) {
            // Check if the date is already present in chartData
            var existingEntryIndex = chartData.indexWhere((entry) => entry.date == log.date);

            if (existingEntryIndex != -1) {
              // Date already exists, update the count
              chartData[existingEntryIndex].count += 1;
            } else {
              // Date doesn't exist, add a new entry
              chartData.add(ChartData(date: log.date, count: 1));
            }
          });
          return SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
            ),
            series: <CartesianSeries>[
              LineSeries<ChartData, String>(
                color: Colors.indigo,
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.date,
                  yValueMapper: (ChartData data, _) => data.count,
                  markerSettings: MarkerSettings(isVisible: true))
            ],
          );
        }
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String message;
  final String imageUrl;
  final Timestamp timestamp;
  final VoidCallback onPressed;
  final String userUID;

  const ActivityCard(
      {Key? key,
        required this.title,
        required this.message,
        required this.imageUrl,
        required this.timestamp,
        required this.userUID,
        required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _navigateToUserProfile(String userId) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: AdminUserDetails(userId: userId),
        withNavBar: false,
      );
    }
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              _navigateToUserProfile(userUID);
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black87)],
                border: Border.all(color: Colors.black87),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
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
            title ?? 'No title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message ?? 'No message', style: TextStyle(fontSize: 12),),
              SizedBox(height: 4),
              Text(
                "${_formatTimestamp(timestamp)}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
    return formattedDate;
  }
}

class ChartData {
  final String date;
  int count;

  ChartData({required this.date, required this.count});
}
