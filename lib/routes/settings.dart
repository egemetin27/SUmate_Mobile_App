import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services/auth.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';

class SettingsAll extends StatefulWidget {
  const SettingsAll({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _SettingsAll createState() => _SettingsAll();
}

class _SettingsAll extends State<SettingsAll>{

  final AuthService _auth = AuthService();

  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.popUntil(context, ModalRoute.withName('/welcome'));
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'SettingsAll', 'SettingsAllState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Settings',
            //style: mainTitleTextStyle,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 200.0,
                    child: Text(
                      'Change Password',
                      //style: bodyNormalTextStyle,
                    ),
                  ),
                  Container(

                    child: ElevatedButton(
                      onPressed: () {Navigator.pushNamed(context, '/changepassword');},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppColors.primary),
                        elevation: MaterialStateProperty.all(10),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                      ),
                      child: Text(
                        'Press',
                        //style: bodyNormalTextStyle,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 200.0,
                    child: Text(
                      'Deactivate Account',
                      //style: bodyNormalTextStyle,
                    ),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {Navigator.pushNamed(context, '/deactivateaccount');},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppColors.primary),
                        elevation: MaterialStateProperty.all(10),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                      ),
                      child: Text(
                        'Press',
                        //style: bodyNormalTextStyle,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 200.0,
                    child: Text(
                      'Delete Account',
                      //style: bodyNormalTextStyle,
                    ),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {Navigator.pushNamed(context, '/deleteaccount');},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(AppColors.primary),
                        elevation: MaterialStateProperty.all(10),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                      ),
                      child: Text(
                        'Press',
                        //style: bodyNormalTextStyle,
                      ),
                    ),
                  )
                ],
              ),
              Spacer(flex: 1,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text("Log Out"),
                                content: Text("Are you sure to log out?"),
                                actions: [
                                  FlatButton(onPressed: (){ Navigator.of(context).pop(); }, child: Text('No')),
                                  FlatButton(onPressed: (){ Navigator.of(context).pop(); signOut(); }, child: Text('Yes')), //go to welcome page
                                ],
                              );
                            }
                        );
                      },
                      splashRadius: 40,
                      icon: Icon(
                          IconData(0xe3b3, fontFamily: 'MaterialIcons'),
                          color: Colors.red[900]
                      ),
                      iconSize: 65,
                    ),
                    SizedBox(width: 10),
                  ]
              ),
            ],
          ),
        )
    );
  }
}

/*


 */