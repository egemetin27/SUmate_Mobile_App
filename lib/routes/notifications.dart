import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:sumate_mobile_app/classes/models.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Notifications', 'NotificationsState');
    updatePage();
  }

  List<dynamic> userNotifisRaw = [];
  List<Notificat> userNotifis = [];

  Future<void> updatePage() async {
    await FirebaseFirestore.instance.collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then(
            (DocumentSnapshot documentSnapshot) {
          setState(() {
            userNotifisRaw = documentSnapshot['userNotifications'];
          });
        }
    );
    for (var i in userNotifisRaw) {
      userNotifis.add(Notificat.fromMap(i));
    }
    setState(() {
      notifications = userNotifis;
    });
  }

  List<Notificat> notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/notifications'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(0xe450, fontFamily: 'MaterialIcons'),
                  color: Colors.black
              ),
              iconSize: 35,
            ),
            Text(
              'Notifications',
              //style: mainTitleTextStyle,
            ),
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/messages'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(0xe3e0, fontFamily: 'MaterialIcons'),
                  color: Colors.black
              ),
              iconSize: 35,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        elevation: 0.0,
      ),
      body: Container(
        color: AppColors.background,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          padding: EdgeInsets.all(0.0),
          children: notifications.map(
                  (notification) => NotificationSection(
                currNotification: notification,
              )
          ).toList(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.secondary,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () {Navigator.pushNamed(
                  context, '/feed');},
              splashRadius: 30,
              icon: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
              iconSize: 45,
            ),

            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/search'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(0xf1ad, fontFamily: 'MaterialIcons'),
                  color: Colors.black
              ),
              iconSize: 45,
            ),

            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/profile'); },
              splashRadius: 30,
              icon: Icon(
                  IconData(0xe491, fontFamily: 'MaterialIcons'),
                  color: Colors.black
              ),
              iconSize: 45,
            ),
          ],
        ),
      ),
    );
  }
}