import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:sumate_mobile_app/classes/models.dart';

class Followers extends StatefulWidget {
  const Followers({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {

  List<AppUser> users = [];
  String username = '';

  Future<void> updateList() async {
    users.clear();
    await FirebaseFirestore.instance.collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (followersString.contains(doc.id)) {
          users.add(AppUser.fromMap(doc.data()));
        }
      });
    });
    setState(() {});
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  //List<AppUser> followersUsers = [];
  late Map<dynamic, dynamic> elements;
  List<String> followersString = [];
  String currUsername = "";

  @override
  void initState() {
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Followers', 'FollowersState');
    super.initState();
    updateList();
  }

  @override
  Widget build(BuildContext context) {
    elements = ModalRoute.of(context)!.settings.arguments as Map;
    followersString = elements["followers"];
    currUsername = elements["username"];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          "Followers",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        elevation: 0.0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.height,
        height: MediaQuery.of(context).size.height,
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 10/11,
              height: MediaQuery.of(context).size.height * 8/10,
              child: ListView(
                padding: EdgeInsets.all(0.0),
                children: users.map(
                        (user) => UsersSection(
                        user: user
                    )
                ).toList(),
              ),
            ),
            SizedBox(),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}