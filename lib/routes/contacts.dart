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

class Contacts extends StatefulWidget {
  const Contacts({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  List<AppUser> users = [
    AppUser(username: 'username #1', email: '', phoneNumber: '', password: '', postCount: 0, followersCount: 0, followingCount: 0, bio: 'desc #1', isPrivate: true, profilePhoto: '', profilePhotoUrl: '', isDeactivated: false,),
    AppUser(username: 'username #2', email: '', phoneNumber: '', password: '', postCount: 0, followersCount: 0, followingCount: 0, bio: 'desc #2', isPrivate: true, profilePhoto: '', profilePhotoUrl: '', isDeactivated: false,),
  ];

  User? firebaseUser = FirebaseAuth.instance.currentUser;
  late String username, followersCount, followingCount, profilePhoto;
  late List<dynamic> userFollowingRaw;
  late List<String> userFollowing = [];

  Future<void> loadContacts() async{
    users.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        print("fafas");
        username = documentSnapshot['username'];
        //followersCount = documentSnapshot['followersCount'];
        //followingCount = documentSnapshot['followingCount'];
        profilePhoto = documentSnapshot['profilePhoto'];
        //userFollowersRaw = documentSnapshot['userFollowers'];
        userFollowingRaw = documentSnapshot['userFollowing'];
      });
    });
    for (var i in userFollowingRaw) {
      userFollowing.add(i);
    }
    await FirebaseFirestore.instance.collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (userFollowing.contains(doc.id)) {
          users.add(AppUser.fromMap(doc.data()));
        }
      });
    });
  }


  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    loadContacts();
    setCurrentScreen(widget.analytics, widget.observer, 'Contacts', 'ContactsState');
  }



  @override
  Widget build(BuildContext context) {
    //loadContacts();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xe450, fontFamily: 'MaterialIcons'),
                  color: Colors.black),
              iconSize: 35,
            ),
            Text(
              'SUmate',
              //style: mainTitleTextStyle,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/messages');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xe3e0, fontFamily: 'MaterialIcons'),
                  color: Colors.black),
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
        width: MediaQuery.of(context).size.width * 19/20,
        height: MediaQuery.of(context).size.height * 17/20,
        child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width * 18/20,
                height: MediaQuery.of(context).size.height * 14/20,
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
      bottomNavigationBar: BottomAppBar(
        color: AppColors.secondary,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/feed');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
              iconSize: 45,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xf1ad, fontFamily: 'MaterialIcons'),
                  color: Colors.black),
              iconSize: 45,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xe491, fontFamily: 'MaterialIcons'),
                  color: Colors.black),
              iconSize: 45,
            ),
          ],
        ),
      ),
    );
  }
}