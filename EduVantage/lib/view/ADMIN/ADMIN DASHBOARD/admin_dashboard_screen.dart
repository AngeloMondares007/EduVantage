import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/ADMIN/ADMIN DASHBOARD/admin_home/admin_home.dart';
import 'package:tech_media/view/ADMIN/ADMIN DASHBOARD/admin_vantageAI/admin_vantage.dart';

import 'admin_chat/admin_user/AdminUserLIst.dart';
import 'admin_logs/admin_logs.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);


  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {


  final controller = PersistentTabController(initialIndex: 0);
  List <Widget>_buildScreen(){

    return [
      AdminHomeScreen(),
      AdminLogsScreen(),
      // AdminLearningToolsScreen(),
      AdminUserListScreen(),
      AdminVantage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItem(){
    return[
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home, size: 24),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.news),
        title: ("Activity"),
        activeColorPrimary: CupertinoColors.systemIndigo,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      // PersistentBottomNavBarItem(
      //   icon: Icon(CupertinoIcons.book),
      //   title: ("Tools"),
      //   activeColorPrimary: CupertinoColors.systemYellow,
      //   inactiveColorPrimary: CupertinoColors.systemGrey,
      // ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person_3),
        title: ("Users"),
        activeColorPrimary: CupertinoColors.destructiveRed,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.graph_square),
        title: ("Statistics"),
        activeColorPrimary: CupertinoColors.activeGreen,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return PersistentTabView(
        context,
        screens: _buildScreen(),
          items: _navBarItem(),
      controller: controller,
      backgroundColor: Color(0xFFe5f3fd),
      decoration: NavBarDecoration(
        colorBehindNavBar: Color(0xFFe5f3fd),
        borderRadius: BorderRadius.circular(15),
    ),
      navBarStyle: NavBarStyle.style3, //style 1,3,6



    );
  }
}
