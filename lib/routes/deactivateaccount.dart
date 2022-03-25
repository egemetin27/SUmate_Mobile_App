import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services/auth.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';

class DeactivateAccount extends StatefulWidget {
  const DeactivateAccount({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _DeactivateAccountState createState() => _DeactivateAccountState();
}

class _DeactivateAccountState extends State<DeactivateAccount> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  final AuthService _auth = AuthService();

  User? firebaseUser = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> signOut() async {
    users.doc(firebaseUser!.uid).update({'isDeactivated': true});
    await _auth.signOut();
    Navigator.popUntil(context, ModalRoute.withName('/welcome'));
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'DeactivateAccount', 'DeactivateAccountState');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Deactivate Account',
          //style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Reminder',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xFF280505),
                  fontWeight: FontWeight.bold,
                  fontSize: 40,

                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'After the deactivaton process you can',
                  //style: bodySmallTextStyle
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'activate your account whenever you want.',
                  //style: bodySmallTextStyle
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: () {showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Deactivate account"),
                          content: Text("Are you sure to deactivate your account?"),
                          actions: [
                            FlatButton(onPressed: (){ Navigator.of(context).pop(); }, child: Text('No')),
                            FlatButton(onPressed: (){ Navigator.of(context).pop(); signOut(); }, child: Text('Yes')), //go to welcome page
                          ],
                        );
                      }
                  );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColors.primary),
                    elevation: MaterialStateProperty.all(10),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                  ),
                  child: Text(
                    'Deactivate',
                    //style: bodyNormalTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
