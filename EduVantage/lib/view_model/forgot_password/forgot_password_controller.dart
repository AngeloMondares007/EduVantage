import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';


class ForgotPasswordController with ChangeNotifier{


  FirebaseAuth auth = FirebaseAuth.instance;




  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();

  }
  void forgotPassword (BuildContext context, String email)async{

    setLoading(true);

    try {

      auth.sendPasswordResetEmail(
          email: email,
      ).then((value){

        setLoading(false);
        Navigator.pushNamed(context, RouteName.loginView);

        Utils.toastMessage('Please check your email to recover your password');

      }).onError((error, stackTrace){
        setLoading(false);
        Utils.toastMessage(error.toString());

      });

    }catch(e){
      setLoading(false);
      Utils.toastMessage(e.toString());
    }

  }


}