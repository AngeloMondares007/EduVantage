
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_chat/admin_user/UserDetails.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tech_media/view/dashboard/chat/messages_screen.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.reference().child('User');
  String filter = ""; // Search filter string
  String? selectedDepartment; // Selected department
  String? selectedCourse; // Selected course
  List<DocumentSnapshot>? userRecentActivity; // Change to List<DocumentSnapshot>?
  String? _selectedSortOption; // Variable to track the selected sorting option

  // Define courses mapped to each department
  final Map<String, List<String>> coursesByDepartment = {
    'CAS': ['BS Architecture', 'BS Civil Engineering', 'BS Computer Engineering',
      'BS Electronics Engineering', 'BS Electrical Engineering',
      'BS Mechanical Engineering', 'BA Communication', 'BA Political Science', 'Bachelor of Elementary Education',
      'BSED - Science', 'BSED - Social Studies',
      'BSED - English', 'BSED - Math', 'BS Information Technology', 'Associate in Computer Technology', 'BS Accountancy', 'BS AIS (AcctgTech)', 'BS Management Accounting',
      'BSBA - Financial Management', 'BSBA - Marketing Management',
      'BS Tourism Management', 'BS Hospitality Management', 'BS Medical Laboratory', 'BS Nursing', 'BS Pharmacy', 'BS Psychology', 'BS Criminology' ],

    'CEA': ['BS Architecture', 'BS Civil Engineering', 'BS Computer Engineering',
      'BS Electronics Engineering', 'BS Electrical Engineering',
      'BS Mechanical Engineering'],

    'CELA': ['BA Communication', 'BA Political Science', 'Bachelor of Elementary Education',
      'BSED - Science', 'BSED - Social Studies',
      'BSED - English', 'BSED - Math'],

    'CITE' : ['BS Information Technology', 'Associate in Computer Technology'],

    'CMA': ['BS Accountancy', 'BS AIS (AcctgTech)', 'BS Management Accounting',
      'BSBA - Financial Management', 'BSBA - Marketing Management',
      'BS Tourism Management', 'BS Hospitality Management'],

    'CAHS': ['BS Medical Laboratory', 'BS Nursing', 'BS Pharmacy', 'BS Psychology'],

    'CCJE': ['BS Criminology'],
  };

  bool _isLoading = true; // Add this variable to track loading state

  @override
  void initState() {
    super.initState();
    fetchRecentUserActivity();
  }

  // Function to handle the pull-to-refresh action
  Future<void> _refreshData() async {
    // Add your data fetching logic here, if needed
    // For example, you can update the data from the Firebase database

    // Delay for a few seconds to simulate data fetching
    await Future.delayed(Duration(seconds: 2));

    // Call setState to rebuild the widget after data is fetched
    setState(() {});
  }

  Future<void> fetchRecentUserActivity() async {
    try {
      var lastActivity = await FirebaseFirestore.instance.collection('ActivityLogs').orderBy("timestamp", descending: true).get();
      setState(() {
        userRecentActivity = lastActivity.docs;
        _isLoading = false; // Data fetched, set loading state to false
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Error occurred, set loading state to false
      });
      print('Error fetching user activity: $e');
    }
  }

  String calculateEngagementStatus(String userId) {
    var lastActivityTimestamp;
    for (var data in userRecentActivity!) {
      if (data['userId'] == userId) {
        lastActivityTimestamp = data['timestamp'];
        break;
      }
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lastActivityTimestamp != null) {
      final timeDifference =
          currentTime - lastActivityTimestamp.millisecondsSinceEpoch;
      if (timeDifference <= Duration(days: 7).inMilliseconds) {
        return 'Active';
      } else if (timeDifference <= Duration(days: 30).inMilliseconds) {
        return 'Moderate';
      } else {
        return 'Inactive';
      }
    } else {
      return 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFe5f3fd),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          centerTitle: false,
          title: Text(
            'User Management',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: AppFonts.alatsiRegular,
            ),
          ),
          backgroundColor: Color(0xFFe5f3fd),
          elevation: 0,
          actions: [
            // Dropdown button for sorting options
            DropdownButton<String>(
              value: _selectedSortOption ?? 'Alphabetically', // Set default value to 'Alphabetically' if no option is selected
              iconSize: 24,
              elevation: 1,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(15),
              style: TextStyle(color: Colors.black),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSortOption = newValue;
                });
              },
              items: <String>[
                'Alphabetically',
                'Active',
                'Moderate',
                'Inactive',
              ].map<DropdownMenuItem<String>>((String value) {
                IconData? icon;
                if (value == 'Active') {
                  icon = Icons.check_circle;
                } else if (value == 'Moderate') {
                  icon = Icons.access_time;
                } else if (value == 'Inactive') {
                  icon = Icons.cancel;
                } else if (value == 'Alphabetically') {
                  icon = Icons.sort_by_alpha;
                }

                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      if (icon != null) Icon(icon, color: Colors.black, size: 20), // Display icon if available
                      SizedBox(width: 8),
                      Text(value, style: TextStyle(fontFamily: AppFonts.alatsiRegular),),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.transparent),
                    color: Colors.white,  // Change the color here
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search a user',
                        prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey,),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w100, fontSize: 18),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w300),
                      onChanged: (value) {
                        setState(() {
                          filter = value;
                        });
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ['All', 'CAS', 'CEA', 'CELA', 'CITE', 'CMA', 'CAHS', 'CCJE'].length,
                    itemBuilder: (context, index) {
                      final department = ['All', 'CAS', 'CEA', 'CELA', 'CITE', 'CMA', 'CAHS', 'CCJE'][index];
                      return Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDepartment = department == 'All' ? null : department;
                              selectedCourse = null; // Reset selected course when department changes
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDepartment == department ? Colors.deepOrange : Colors.black,
                          ),
                          child: Text(
                            department,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.alatsiRegular,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),

              if (selectedDepartment != null)
                SizedBox(
                  height: 35,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: coursesByDepartment[selectedDepartment!]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final course = coursesByDepartment[selectedDepartment!]?[index];
                        return Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedCourse = course;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedCourse == course ? Colors.blue : Colors.black54,
                            ),
                            child: Text(
                              course ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: AppFonts.alatsiRegular,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(),
                ) : userRecentActivity == null || userRecentActivity!.isEmpty
                    ? Center(
                  child: Text('No users found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black45),),
                )
                    : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: FirebaseAnimatedList(
                    query: ref.orderByChild('userName'),
                    itemBuilder: (context, snapshot, animation, index) {
                      if (SessionController().userId.toString() == snapshot.key) {
                        return Container();
                      }
                      final userName = snapshot.child('userName').value?.toString() ?? "";
                      final email = snapshot.child('email').value?.toString() ?? "";
                      final image = snapshot.child('profile').value?.toString() ?? "";
                      final receiverId = snapshot.key ?? "";

                      final userDepartment = snapshot.child('department').value?.toString() ?? "";
                      final userCourse = snapshot.child('course').value?.toString() ?? "";

                      bool isUserDeactivated = snapshot.child('status').value == 'disabled';

                      // Filter users based on the selected sorting option
                      if ((_selectedSortOption == null ||
                          _selectedSortOption == 'Alphabetically' ||
                          (_selectedSortOption == 'Active' &&
                              calculateEngagementStatus(snapshot.child('uid').value?.toString() ?? "") == 'Active') ||
                          (_selectedSortOption == 'Moderate' &&
                              calculateEngagementStatus(snapshot.child('uid').value?.toString() ?? "") == 'Moderate') ||
                          (_selectedSortOption == 'Inactive' &&
                              calculateEngagementStatus(snapshot.child('uid').value?.toString() ?? "") == 'Inactive')) &&
                          ((selectedDepartment == null || userDepartment == selectedDepartment) &&
                              (selectedCourse == null || userCourse == selectedCourse) &&
                              (userName.toLowerCase().contains(filter.toLowerCase()) ||
                                  email.toLowerCase().contains(filter.toLowerCase())))) {
                        return _buildUserTile(
                          name: userName,
                          image: image,
                          email: email,
                          receiverId: receiverId,
                          engagementStatus: calculateEngagementStatus(snapshot.child('uid').value?.toString() ?? ""),
                          isDeactivated: isUserDeactivated,
                        );
                      } else {
                        return Container();
                      }

                    },
                  ),
                ),
              ), ]
        ),
      ),
    );
  }

  Widget _buildUserTile({
    required String name,
    required String image,
    required String email,
    required String receiverId,
    required String engagementStatus,
    required bool isDeactivated,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          _navigateToMessageScreen(receiverId, name, image);
        },
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _navigateToUserProfile(receiverId);
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black87)],
                      border: Border.all(color: Colors.black87),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      placeholder: (context, url) =>
                          Icon(CupertinoIcons.person, color: Colors.white, size: 26,),
                      errorWidget: (context, url, error) =>
                          Icon(CupertinoIcons.person, color: Colors.white, size: 26,),
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
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 3),
                      Text(
                        email,
                        style: TextStyle(fontSize: 13, color: Colors.black54), softWrap: true, overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Engagement: $engagementStatus',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      if (isDeactivated)
                        Row(
                          children: [
                            Text(
                              'User is deactivated',
                              style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                _activateUser(receiverId); // Call the _activateUser method
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.toggle_on_outlined, color: Colors.green, size: 24,),
                                  SizedBox(width: 4),
                                  Text(
                                    'Activate', // Text for activation action
                                    style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isDeactivated ? null : () {
                    _deleteUser(receiverId);
                  },
                  icon: Icon(Icons.toggle_off_outlined, color: isDeactivated ? Colors.grey : Colors.red, size: 24,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _navigateToMessageScreen(String receiverId, String name, String image) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: MessagesScreen(
        name: name,
        image: image,
        receiverId: receiverId, email: '',
      ),
      withNavBar: false,
    );
  }


  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          elevation: 0,
          backgroundColor: Colors.white,

          title: Text("Confirm Deactivation", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
          content: Text("Are you sure you want to deactivate this user?", style: TextStyle(fontSize: 14),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDisableUser(userId);
                // _performDeleteUser(userId);
              },
              child: Text("Deactivate", style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  void _activateUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          elevation: 0,
          backgroundColor: Colors.white,

          title: Text("Confirm Activation", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
          content: Text("Are you sure you want to activate this user?", style: TextStyle(fontSize: 14),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performEnableUser(userId);
                // _performDeleteUser(userId);
              },
              child: Text("Activate", style: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: Colors.black),),
            ),
          ],
        );
      },
    );
  }



  // void deleteUser(String userId) async {
  //   try {
  //     var response = await http.delete(Uri.parse('http://localhost:3000/users/$userId'));
  //     if (response.statusCode == 200) {
  //       print('User deleted successfully');
  //     } else {
  //       print('Failed to delete user. Status code: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error deleting user: $e');
  //   }
  // }
  //
  // Future<void> _performDeleteUser(String userId) async {
  //   DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User').child(userId);
  //   deleteUser(userId);
  //   userRef.remove().then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('User deactivated successfully'),
  //         behavior: SnackBarBehavior.floating,
  //         margin: EdgeInsets.only(bottom: 17),
  //       ),
  //     );
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('User deactivated successfully'),
  //         behavior: SnackBarBehavior.floating,
  //         margin: EdgeInsets.only(bottom: 17),
  //       ),
  //     );
  //   });
  // }
  //
  //

  // void deactivateUser(String userId) async {
  //   try {
  //     var response = await http.delete(Uri.parse('http://localhost:3000/users/$userId'));
  //     if (response.statusCode == 200) {
  //       print('User deactivated successfully');
  //     } else {
  //       print('Failed to deactivate user. Status code: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error deactivating user: $e');
  //   }
  // }

  Future<void> _performDisableUser(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User').child(userId);

    // deactivateUser(userId);

    // Update user status to disabled
    await userRef.update({'status': 'disabled'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deactivated successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 17),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deactivating user'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 17),
        ),
      );
    });
  }

  Future<void> _performEnableUser(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User').child(userId);

    // deactivateUser(userId);

    // Update user status to disabled
    await userRef.update({'status': 'enabled'}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User activated successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 17),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error activating user'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 17),
        ),
      );
    });
  }


  void _navigateToUserProfile(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AdminUserDetails(userId: userId),
      withNavBar: false,
    );
  }
}