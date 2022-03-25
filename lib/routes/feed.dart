import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumate_mobile_app/classes/models.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:sumate_mobile_app/utils/color.dart';

import '../classes/classes.dart';

class Feed extends StatefulWidget {
  const Feed({Key, key, required this.analytics, required this.observer})
      : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  List<dynamic> userFollowingRaw = [];
  List<String> userFollowing = [];

  Future<void> loadFeed() async {
    await userCollection
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        userFollowingRaw = documentSnapshot['userFollowing'];
      });
    });
    for (var i in userFollowingRaw) {
      userFollowing.add(i.toString());
      //print(userFollowingRaw);
    }
    //print(userFollowing);
    posts.clear();
    for (var i in userFollowing) {
      //print(i);
      FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isEqualTo: i)
          .where('isDeactivated', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          for (var j in doc["usersPosts"]) {
            setState(() {
              posts.add(Post.fromMap(j));
            });
          }
        });
      });
    }
    setState(() {
      posts.shuffle(Random());
    });
    //print(posts);
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  List<Post> posts = [];

  bool isEnteredApp = false;

  loadEnteredAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnteredApp = prefs.getBool('enteredApp')!;
    });
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    loadFeed();
    loadEnteredAppStatus();
    setCurrentScreen(widget.analytics, widget.observer, 'Feed', 'FeedState');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(!isEnteredApp);
      },
      child: Scaffold(
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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: EdgeInsets.only(top: 8.0),
            children: posts
                .map((post) => PostsOthersSection(
                      post: post,
                      like: () {},
                      dislike: () {},
                      makeComment: () {},
                      bookmark: () {},
                      share: () {},
                    ))
                .toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          splashColor: AppColors.background,
          onPressed: () {
            Navigator.pushNamed(context, '/createPostView');
          },
          child: Text("  New  \n  Post"),
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
      ),
    );
  }
}
