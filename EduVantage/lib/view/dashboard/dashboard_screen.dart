import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/dashboard/chat/user/user_list_screen.dart';
import 'package:tech_media/view/dashboard/tools/tools.dart';
import 'package:tech_media/view/dashboard/tasks/tasks.dart';

import 'home/home.dart';

PersistentTabController tabController = PersistentTabController(initialIndex: 0);

class DashboardScreen extends StatefulWidget {
  final String userUID; // Add the userUID parameter
  DashboardScreen({required this.userUID, Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var controller;
  @override
  void initState() {
    super.initState();
    setState(() {
      controller = tabController;
    });
  }
  List <Widget>_buildScreen(){

    return [
      HomeScreen(userUID: widget.userUID), // Pass userUID to HomeScreen
      TaskScreen(userUID: widget.userUID,),
      LearningToolsScreen(userUID: widget.userUID),
      UserListScreen(userUID: widget.userUID),
      // Vantage(userUID: widget.userUID,),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItem(){
    return[
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: Colors.green.shade800,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        // inactiveIcon: Icon(CupertinoIcons.home),
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.calendar_today),
        title: ("Tasks"),
        activeColorPrimary: CupertinoColors.systemIndigo,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.book),
        title: ("Tools"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        // inactiveIcon: Icon(CupertinoIcons.book),
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.chat_bubble_2),
        title: ("Contacts"),
        activeColorPrimary: CupertinoColors.destructiveRed,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        // inactiveIcon: Icon(CupertinoIcons.chat_bubble_2),
      ),
      // PersistentBottomNavBarItem(
      //   icon: Icon(CupertinoIcons.chart_bar),
      //   title: ("V Stats"),
      //   activeColorPrimary: CupertinoColors.activeGreen,
      //   inactiveColorPrimary: CupertinoColors.systemGrey,
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return PersistentTabView(
      context,
      stateManagement: (controller.index==4) ? false : true,
      screens: _buildScreen(),
      items: _navBarItem(),
      controller: controller,
      backgroundColor: Color(0xFFe5f3fd),
      decoration: NavBarDecoration(
        colorBehindNavBar: Color(0xFFe5f3fd),
        borderRadius: BorderRadius.circular(2),
      ),
      navBarStyle: NavBarStyle.style3, //style 1,3,6



    );
  }
}
