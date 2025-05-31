import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_chat/admin_user/UserDetails.dart';

class AdminFeedbackScreen extends StatefulWidget {
  @override
  _AdminFeedbackScreenState createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  late Stream<QuerySnapshot> feedbackStream;
  String _sortOption = 'Name'; // Default sort option

  @override
  void initState() {
    super.initState();
    // Fetch feedback data from Firestore sorted by name initially
    feedbackStream = FirebaseFirestore.instance.collection('Feedback').orderBy('userName').snapshots();
  }

  void _onSortChanged(String value) {
    setState(() {
      _sortOption = value;
      // Update the feedback stream based on the selected sort option
      switch (_sortOption) {
        case 'Name':
          feedbackStream = FirebaseFirestore.instance.collection('Feedback').orderBy('userName').snapshots();
          break;
        case 'Department':
          feedbackStream = FirebaseFirestore.instance.collection('Feedback').orderBy('userDepartment').snapshots();
          break;
        case 'Star Rating':
          feedbackStream = FirebaseFirestore.instance.collection('Feedback').orderBy('starRating', descending: true).snapshots();
          break;
        default:
          feedbackStream = FirebaseFirestore.instance.collection('Feedback').orderBy('userName').snapshots();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Color(0xFFe5f3fd),
        title: Text('User Feedback', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            elevation: 1,
            color: Colors.black,
            onSelected: _onSortChanged,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Name',
                child: Text('Sort by Name', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.white),),
              ),
              PopupMenuItem<String>(
                value: 'Department',
                child: Text('Sort by Department', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.white),),
              ),
              PopupMenuItem<String>(
                value: 'Star Rating',
                child: Text('Sort by Star Rating', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: feedbackStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true, // Add this line
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot document = snapshot.data!.docs[index];
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String userId = data['userUID']; // Assuming the user ID field is 'userId'
                  return Dismissible(
                    key: Key(document.id),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 165),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            backgroundColor: Colors.white,
                            elevation: 0,
                            title: Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                            content: Text("Are you sure you want to delete this feedback?", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("Cancel", style: TextStyle(fontFamily: AppFonts.alatsiRegular,fontWeight: FontWeight.normal, color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text("Delete", style: TextStyle(fontFamily: AppFonts.alatsiRegular,fontWeight: FontWeight.normal, color: Colors.black)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (DismissDirection direction) {
                      // Delete the item from Firestore
                      FirebaseFirestore.instance.collection('Feedback').doc(document.id).delete();
                    },
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${data['userName']}'),
                                  SizedBox(height: 0), // Add space
                                  Text('${data['userStudentNumber']}'),
                                  SizedBox(height: 0), // Add space
                                  Text('${data['userDepartment']}'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _navigateToUserProfile(userId);
                              },
                              child: Container(
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(data['userProfileImage']),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10), // Add space between username and details
                            Row(
                              children: [
                                Text('Star Rating: '),
                                _buildStarRating(data['starRating']),
                              ],
                            ),

                            Text('Favorite Features: ${data['favoriteFeatures'].join(', ')}'),
                            SizedBox(height: 10), // Add space
                            Text('Suggestions: ${data['suggestions']}'),
                          ],
                        ),
                        // onTap: () {
                        //   // Implement detail view or edit feedback functionality
                        //   // Example: navigateToDetailScreen(document.id);
                        // },
                      ),
                    ),
                  );
                },
              );
            }

            return Center(
              child: Text('No feedback data available'),
            );
          },
        ),
      ),
    );
  }

  void _navigateToUserProfile(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AdminUserDetails(userId: userId),
      withNavBar: false,
    );
  }

  Widget _buildStarRating(int starRating) {
    return Row(
      children: List.generate(starRating, (index) {
        return Icon(Icons.star, color: Colors.amber);
      }),
    );
  }
}
