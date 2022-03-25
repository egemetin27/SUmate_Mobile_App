import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:sumate_mobile_app/services/database.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:sumate_mobile_app/classes/models.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatefulWidget {
  const Profile({Key, key, required this.analytics, required this.observer})
      : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  late List<dynamic> postsRaw;
  late Post post;
  List<Post> posts = [];

  String username = '', bio = '', profilePhoto = '', photoUrl = '';
  int postCount = 0, followersCount = 0, followingCount = 0;

  List<dynamic> userFollowersRaw = [], userFollowingRaw = [];
  List<String> userFollowers = [], userFollowing = [];

  bool isPostClicked = false;

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  Future<void> updatePage() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        username = documentSnapshot['username'];
        bio = documentSnapshot['bio'];
        postCount = documentSnapshot['postCount'];
        followersCount = documentSnapshot['followersCount'];
        followingCount = documentSnapshot['followingCount'];
        profilePhoto = documentSnapshot['profilePhoto'];
        userFollowersRaw = documentSnapshot['userFollowers'];
        userFollowingRaw = documentSnapshot['userFollowing'];
      });
    });
    userFollowers.clear();
    for (var i in userFollowersRaw) {
      userFollowers.add(i);
    }
    userFollowing.clear();
    for (var i in userFollowingRaw) {
      userFollowing.add(i);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (userFollowers.contains(doc.id) && doc["isDeactivated"]) {
          userFollowers.remove(doc.id);
          followersCount--;
        }
      });
    });

    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (userFollowing.contains(doc.id) && doc["isDeactivated"]) {
          userFollowing.remove(doc.id);
          followingCount--;
        }
      });
    });

    setState(() {});
    //print(userFollowers);
    //print(userFollowing);
    //print(profilePhoto);
    if (profilePhoto != '') {
      firebase_storage.Reference firebaseStorageRef =
          firebase_storage.FirebaseStorage.instance.ref().child(profilePhoto);
      final photo = await firebaseStorageRef.getDownloadURL();
      photoUrl = photo.toString();
    } else {
      photoUrl = '';
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      postsRaw = documentSnapshot["usersPosts"];
    });
    for (var e in postsRaw) {
      posts.add(Post.fromMap(e));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updatePage();
    enableCrashlytics();
    setCurrentScreen(
        widget.analytics, widget.observer, 'Profile', 'ProfileState');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
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
                    username == '' ? "SUmate" : '$username',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
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
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(),
                            SizedBox(),
                            //SizedBox(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                //SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipOval(
                                    child: Material(
                                      color: Colors.green,
                                      child: InkWell(
                                        child: CircleAvatar(
                                          backgroundImage: (photoUrl == ''
                                              ? NetworkImage(
                                              "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                                              : NetworkImage(photoUrl)),
                                          backgroundColor: Colors.green,
                                          radius: 40,
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, '/photozoom',
                                              arguments: {
                                                "imageUrl": photoUrl,
                                                "username": username
                                              });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 70,
                                  height: 45,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        postCount.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Posts',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/followers',
                                        arguments: {
                                          "followers": userFollowers,
                                          "username": username
                                        });
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 45,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          followersCount.toString(),
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Followers',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/following',
                                        arguments: {
                                          "following": userFollowing,
                                          "username": username,
                                        });
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 45,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          followingCount.toString(),
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Following',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Container(
                                width: 350,
                                height: 48,
                                child: Text(
                                  'Bio:\n$bio',
                                ),
                            ),
                            Divider(
                              height: 2,
                              color: AppColors.primary,
                            ),
                            Container(
                              width: 300,
                              height: 50,
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () { Navigator.pushNamed(context, '/profilesettings'); },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(AppColors.primary),
                                              elevation: MaterialStateProperty.all(10),
                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                                            ),
                                            child: Text(
                                              'Edit your profile',
                                              //style: bodySmallTextStyle,
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 350,
                              height: 390,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 350,
                                    height: 390,
                                    child: ListView(
                                      padding: EdgeInsets.all(0.0),
                                      children: posts.map((post) => PostsOwnSection(
                                        post: post,
                                        like: () {},
                                        dislike: () {},
                                        makeComment: () {},
                                        delete: () {},
                                        share: () {},
                                      ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ],
                )
              ),
            ),
            bottomNavigationBar:BottomAppBar(
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
                    onPressed: () { Navigator.pushNamed(context, '/settings'); },
                    splashRadius: 30,
                    icon: Icon(
                        IconData(0xe57f, fontFamily: 'MaterialIcons'),
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
        });
  }
}
