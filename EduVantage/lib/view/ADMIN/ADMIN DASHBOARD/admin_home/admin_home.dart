import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_home/user_activities.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_home/user_logs.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../admin_chat/admin_user/UserDetails.dart';
import '../admin_profile/admin_profile.dart';

class User {
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? userId;
  final String? department;
  final String? course;

  User({this.name, this.email, this.imageUrl, this.userId, this.department, this.course});
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late List<User> userList;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController searchController;
  String searchQuery = '';
  String? selectedFilter;
  List<String> filterOptions = ['All','CAS', 'CEA', 'CELA', 'CITE','CMA', 'CAHS', 'CCJE', ]; // Update with your filter options

  // List of predefined colors
  List<Color> cardColors = [
    Colors.green.shade800,
    Colors.yellow.shade800,
    // Colors.blue,
    // Colors.red,
    // Colors.purple,
    // Colors.teal,
    // Colors.cyan,
    // Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    userList = [];
    searchController = TextEditingController();
    searchController.addListener(onSearchTextChanged);
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final ref = FirebaseDatabase.instance.reference();
    final snapshot = await ref.child('User').get();
    if (snapshot.exists) {
      List<User> users = [];
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?; // Explicit cast
      if (values != null) {
        values.forEach((key, value) {
          String userId = value['uid']; // Add userId here
          if (userId != '6K5yENRTbKQfYcyZS9hnzQfujjC2') { // Exclude the specific user
            users.add(User(
              userId: userId,
              name: value['userName'],
              email: value['email'],
              imageUrl: value['profile'], // Assuming 'imageUrl' key in Firebase
              department: value['department'], // Add department
              course: value['course'], // Add course
            ));
          }
        });

        // Sort the userList alphabetically by the name
        users.sort((a, b) => a.name!.compareTo(b.name!));

        setState(() {
          userList = users;
        });
      }
    } else {
      print('No data available.');
    }
  }

  void onSearchTextChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  Future<void> _refreshUsers() async {
    await fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFe5f3fd),
      appBar: PreferredSize(
        child: getAppBar(),
        preferredSize: Size.fromHeight(60),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: getBody(),
      ),
    );
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFFe5f3fd),
      title: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "EduVantage | ADMIN",
              style: TextStyle(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.alatsiRegular,
              ),
            ),
            IconButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AdminProfileScreen(),
                  withNavBar: false,
                );
              },
              icon: Icon(
                CupertinoIcons.person_alt_circle_fill,
                color: Colors.black87.withOpacity(0.9),
                size: 35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    List<User> filteredUsers = userList.where((user) {
      bool matchesSearch = user.name!.toLowerCase().contains(searchQuery) ||
          user.email!.toLowerCase().contains(searchQuery); // Include email filtering
      bool matchesFilter =
          selectedFilter == null || selectedFilter == 'All' || user.department == selectedFilter;
      // bool excludeUser = user.userId == '6K5yENRTbKQfYcyZS9hnzQfujjC2';
      return matchesSearch && matchesFilter;
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.transparent, // Change the border color here
                      ),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search a user',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchController.text.isEmpty
                            ? SizedBox.shrink()  // If empty, hide the clear icon
                            : IconButton(
                          onPressed: () => searchController.clear(),
                          icon: Icon(Icons.clear, color: Colors.grey, size: 16,),
                        ),
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none, // Remove the default border
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal),
                      onChanged: (value) {
                        setState(() {});  // Update the state to rebuild the widget
                      },
                    ),
                  ),

                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Colors.white,
                  value: selectedFilter ?? filterOptions.first,
                  items: filterOptions.map((String filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            // Display Users in a Grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                User user = filteredUsers[index];
                Color color = cardColors[index % cardColors.length];
                return GestureDetector(
                  onTap: () {
                    navigateToUserActivity(user.userId ?? '');
                    // navigateToUserLogs(context, user.name ?? '', user.userId ?? '');
                  },
                  child: Card(
                    color: color,
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              navigateToUserDetails(user.userId ?? '');
                            },
                            child: ClipOval(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: user.imageUrl != null
                                    ? CachedNetworkImage(
                                  imageUrl: user.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                )
                                    : Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            user.name ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Department: ${user.department ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Course: ${user.course ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void navigateToUserDetails(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AdminUserDetails(userId: userId),
      withNavBar: false,
    );
  }

  void navigateToUserActivity(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: UserActivityScreen(userUID: userId),
      withNavBar: false,
    );
  }


  void navigateToUserLogs(BuildContext context, String userName, String userUID) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: UserLogsScreen(userName: userName),
      withNavBar: false,
    );
  }



}
