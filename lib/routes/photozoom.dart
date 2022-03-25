import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';

class ZoomedPhoto extends StatefulWidget {
  const ZoomedPhoto({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ZoomedPhotoState createState() => _ZoomedPhotoState();
}

class _ZoomedPhotoState extends State<ZoomedPhoto> {

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  late Map<dynamic, dynamic> elements;
  String imageUrl = '';
  late String username;

  Future<void> loadApp() async {
    imageUrl = elements["imageUrl"];
    username = elements["username"];
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'ZoomedPhoto', 'ZoomedPhotoState');
  }

  @override
  Widget build(BuildContext context) {
    elements = ModalRoute.of(context)!.settings.arguments as Map;
    loadApp();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          '$username',
          //style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.0,
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.network(
                imageUrl == '' ? "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png" : imageUrl,
              ),
              margin: EdgeInsets.symmetric(horizontal: 37),
            ),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}