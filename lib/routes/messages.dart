import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:sumate_mobile_app/classes/models.dart';

class DirectMessagesPublic extends StatefulWidget {
  const DirectMessagesPublic({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _DirectMessagesPublicState createState() => _DirectMessagesPublicState();
}

class _DirectMessagesPublicState extends State<DirectMessagesPublic> {

  List<AppUser> users = [];

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'DirectMessagesAll', 'DirectMessagesAllState');
  }

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
            ),              Text(
              'Messages',
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
        width: 450,
        height: 650,
        child: users == [] ? Center(child: Text("No Messages")) : Column(
            children: <Widget>[
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width * 11/12,
                height: 550,
                child: ListView(
                  padding: EdgeInsets.all(0.0),
                  children: users.map(
                          (user) => UsersMessagesSection(
                          user: user
                      )
                  ).toList(),
                ),
              ),
            ]
        ),
      ),
      floatingActionButton:FloatingActionButton(backgroundColor: AppColors.primary,
        splashColor: AppColors.background,
        onPressed: () { Navigator.pushNamed(context, '/contacts'); },
        child: Icon(Icons.add),//add post
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
            /*
              IconButton(
                onPressed: () { Navigator.pushNamed(context, '/messagesall'); },
                splashRadius: 30,
                icon: Icon(
                    IconData(61858, fontFamily: 'MaterialIcons'),
                    color: AppColors.text
                ),
                iconSize: 45,
              ),

               */
          ],
        ),
      ),
    );
  }
}