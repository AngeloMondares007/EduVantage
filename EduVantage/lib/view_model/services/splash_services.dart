import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

class SplashServices {



 void isLogin(BuildContext context){

   FirebaseAuth auth = FirebaseAuth.instance;

   final user = auth.currentUser;

   if (user != null){
     SessionController().userId = user.uid.toString();
     Timer(Duration(seconds : 2),  ()=> Navigator.pushReplacementNamed(context, RouteName.dashboardScreen));

   }else {
     Timer(Duration(seconds: 2), () => Navigator.pushReplacementNamed(context, RouteName.loginView));
   }
 }
}