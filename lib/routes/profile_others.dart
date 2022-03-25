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

class ProfileOthers extends StatefulWidget {
  const ProfileOthers(
      {Key, key, required this.analytics, required this.observer})
      : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _ProfileOthersState createState() => _ProfileOthersState();
}

class _ProfileOthersState extends State<ProfileOthers> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  String photoUrl = "", username = "";

  List<dynamic> followersRaw = [];
  List<String> followers = [];

  static Map<String, dynamic> toMap(Notificat notifi) => {
        'userID': notifi.userID,
        'message': notifi.message,
  };

  List<dynamic> currNotifsRaw = [];
  List<String> currNotifs = [];
  bool alreadySentReq = false;

  Future<void> alreadySent() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: user.username)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        followingUsersAccount = doc.id;
      });
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(followingUsersAccount)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      currNotifsRaw = documentSnapshot['userNotifications'];
    });
    for (var i in currNotifsRaw) {
      currNotifs.add(Notificat.fromMap(i).userID);
    }
    if (currNotifs.contains(firebaseUser!.uid)) {
      alreadySentReq = true;
    } else {
      alreadySentReq = false;
    }
  }

  Future<void> followNewUser() async {
    if (user.isPrivate) {
      //requestSend();
      await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user.username)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          followingUsersAccount = doc.id;
        });
      });
      Notificat newRequest =
          Notificat(userID: firebaseUser!.uid, message: 'wants to follow you.');
      await userCollection.doc(followingUsersAccount).update({
        'userNotifications': FieldValue.arrayUnion([toMap(newRequest)])
      });
      setState(() {alreadySentReq = true;});
    } else {
      alreadyFollowing = true;
      await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user.username)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          followingUsersAccount = doc.id;
        });
      });
      userCollection.doc(firebaseUser!.uid).update({
        'userFollowing': FieldValue.arrayUnion([followingUsersAccount])
      });
      userCollection
          .doc(firebaseUser!.uid)
          .update({'followingCount': FieldValue.increment(1)});
      userCollection.doc(followingUsersAccount).update({
        'userFollowers': FieldValue.arrayUnion([firebaseUser!.uid])
      });
      userCollection
          .doc(followingUsersAccount)
          .update({'followersCount': FieldValue.increment(1)});
    }
    setState(() {});
    allUpdate();
  }

  late String followingUsersAccount;
  Future<void> leaveFollowing() async {
      await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: user.username)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          followingUsersAccount = doc.id;
        });
      });
      userCollection.doc(firebaseUser!.uid).update({
        'userFollowing': FieldValue.arrayRemove([followingUsersAccount])
      });
      userCollection
          .doc(firebaseUser!.uid)
          .update({'followingCount': FieldValue.increment(-1)});
      userCollection.doc(followingUsersAccount).update({
        'userFollowers': FieldValue.arrayRemove([firebaseUser!.uid])
      });
      userCollection
          .doc(followingUsersAccount)
          .update({'followersCount': FieldValue.increment(-1)});
      setState(() {
        alreadyFollowing = false;
        alreadySentReq = false;
      });

  }

  bool isHidden = false, alreadyFollowing = false;

  List<dynamic> userFollowersRaw = [], userFollowingRaw = [];
  List<String> userFollowers = [], userFollowing = [];

  void allUpdate() async {
    await loadPosts();
    await updatePage();
  }

  Future<void> loadPosts() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      authUsername = documentSnapshot['username'];
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: user.username)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        posts.clear();
        for (var i in doc["usersPosts"]) {
          posts.add(Post.fromMap(i));
        }
      });
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      followersRaw = documentSnapshot['userFollowing'];
    });
    followers.clear();
    for (var i in followersRaw) {
      followers.add(i.toString());
    }

    await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: user.username)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        followingUsersAccount = doc.id;
      });
    });

    if (followers.contains(followingUsersAccount)) {
      alreadyFollowing = true;
    }
  }

  Future<void> updatePage() async {
    userFollowers.clear();
    userFollowing.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["username"] == user.username) {
          userFollowersRaw = doc["userFollowers"];
          userFollowingRaw = doc["userFollowing"];
        }
      });
    });

    for (var i in userFollowersRaw) {
      userFollowers.add(i.toString());
    }

    for (var i in userFollowingRaw) {
      userFollowing.add(i.toString());
    }

    followersCount = user.followersCount;
    followingCount = user.followingCount;

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
  }

  int followersCount = 0, followingCount = 0;
  late Map<dynamic, dynamic> elements;
  late AppUser user;
  List<Post> posts = [];
  late String authUsername;
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setState(() {});
    setCurrentScreen(widget.analytics, widget.observer, 'ProfileOthers',
        'ProfileOthersState');
  }

  bool loading = true;

  @override
  void didChangeDependencies() {
    if (loading) {
      elements = ModalRoute.of(context)!.settings.arguments as Map;
      user = elements["user"];
      isHidden = user.isPrivate;
      allUpdate();
      loading = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              user.username != "" ? user.username : 'SUmate',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(),
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
                                      backgroundImage: (user.profilePhotoUrl ==
                                              ''
                                          ? NetworkImage(
                                              "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                                          : NetworkImage(user.profilePhotoUrl)),
                                      backgroundColor: Colors.green,
                                      radius: 40,
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(context, '/photozoom',
                                          arguments: {
                                            "imageUrl": user.profilePhotoUrl,
                                            "username": user.username
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
                                    user.postCount.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Posts',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/followers',
                                    arguments: {
                                      "followers": userFollowers,
                                      "username": user.username
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                      "username": user.username,
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Following',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 50,
                              height: 48,
                              child: Text(
                                '\nBio:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              width: 240,
                              height: 50,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Offstage(
                                    offstage: alreadyFollowing || alreadySentReq,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (isHidden) {
                                          await alreadySent();
                                          if (alreadySentReq) {
                                            SnackBar sendFriendRequestSnackBar =
                                                SnackBar(
                                                    content: Text(
                                                        "You already sent a follow request!"));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                    sendFriendRequestSnackBar);
                                          } else {
                                            followNewUser();
                                            SnackBar sendFriendRequestSnackBar =
                                                SnackBar(
                                                    content: Text(
                                                        "You sent a follow request."));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                    sendFriendRequestSnackBar);

                                          }
                                        } else {
                                          followNewUser();
                                        }
                                      },
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(
                                            Size(240, 30)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                AppColors.primary),
                                        elevation:
                                            MaterialStateProperty.all(10),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0))),
                                      ),
                                      child: Text(
                                        'Follow',
                                        //style: bodySmallTextStyle,
                                      ),
                                    ),
                                  ),
                                  Offstage(
                                    offstage: !alreadyFollowing,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        leaveFollowing();
                                      },
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(
                                            Size(240, 32.5)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                AppColors.primary),
                                        elevation:
                                            MaterialStateProperty.all(10),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0))),
                                      ),
                                      child: Text(
                                        'Following',
                                        //style: bodySmallTextStyle,
                                      ),
                                    ),
                                  ),
                                  Offstage(
                                    offstage: !alreadySentReq,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        //leaveFollowing();
                                        setState(() {
                                          alreadyFollowing = false;
                                          alreadySentReq = false;
                                        });
                                      },
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(
                                            Size(240, 32.5)),
                                        backgroundColor:
                                        MaterialStateProperty.all(
                                            AppColors.primary),
                                        elevation:
                                        MaterialStateProperty.all(10),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    20.0))),
                                      ),
                                      child: Text(
                                        'Following Requested',
                                        //style: bodySmallTextStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 350,
                          height: 32,
                          child: Text(
                            '${user.bio}',
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 5,
                          color: AppColors.primary,
                        ),
                      ]),
                  /*Container(
                    //width: MediaQuery.of(context).size.width * 20 / 21,
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Offstage(
                          offstage: !isHidden || alreadyFollowing,
                          child: Container(
                            //width: MediaQuery.of(context).size.width * 19 / 20,
                            height: 395,
                            //color: Colors.green,
                            child: Icon(
                              IconData(59459, fontFamily: 'MaterialIcons'),
                              size: 100,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: !(!isHidden || alreadyFollowing),
                          child: Container(
                            //width: MediaQuery.of(context).size.width * 22 / 23,
                            height: 395,
                            child: ListView(
                              padding: EdgeInsets.all(0.0),
                              children: posts.map(
                                      (post) => PostsOthersSection(
                                    post: post,
                                    like: () {},
                                    dislike: () {},
                                    makeComment: () {},
                                    bookmark: () {},
                                    share: () {},
                                  )
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),
            Container(
              //width: MediaQuery.of(context).size.width * 20 / 21,
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Offstage(
                    offstage: !isHidden || alreadyFollowing,
                    child: Container(
                      //width: MediaQuery.of(context).size.width * 19 / 20,
                      height: 395,
                      //color: Colors.green,
                      child: Icon(
                        IconData(59459, fontFamily: 'MaterialIcons'),
                        size: 100,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !(!isHidden || alreadyFollowing),
                    child: Container(
                      //width: MediaQuery.of(context).size.width * 22 / 23,
                      height: 395,
                      child: ListView(
                        padding: EdgeInsets.all(0.0),
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
                  ),
                ],
              ),
            ),
          ],
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
                Navigator.pushNamed(context, '/settings');
              },
              splashRadius: 30,
              icon: Icon(IconData(0xe57f, fontFamily: 'MaterialIcons'),
                  color: Colors.black),
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

/*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(),
                    ClipOval(
                      child: Material(
                        color: Colors.green,
                        child: InkWell(
                          child: CircleAvatar(
                            backgroundImage: (user.profilePhotoUrl == '' ? NetworkImage("https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png") : NetworkImage(user.profilePhotoUrl)),
                            backgroundColor: Colors.green,
                            radius: 50,
                          ),
                          onTap: () { Navigator.pushNamed(context, '/zoomedphoto', arguments: {"imageUrl": user.profilePhotoUrl, "username": user.username}); },
                        ),
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Center(
                            child: Text(
                              user.username,
                              //style: mainTitleTextStyle,
                            ),
                          ),
                          Offstage(
                            offstage: alreadyFollowing,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (isHidden) {
                                  await alreadySent();
                                  if (alreadySentReq) {
                                    SnackBar sendFriendRequestSnackBar = SnackBar(
                                        content: Text(
                                            "You already sent a follow request!"));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        sendFriendRequestSnackBar);
                                  } else {
                                    followNewUser();
                                    SnackBar sendFriendRequestSnackBar = SnackBar(
                                        content: Text(
                                            "You sent a follow request."));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        sendFriendRequestSnackBar);
                                  }
                                } else {
                                  followNewUser();
                                }
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(200, 32.5)),
                                backgroundColor: MaterialStateProperty.all(AppColors.primary),
                                elevation: MaterialStateProperty.all(10),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                              ),
                              child: Text(
                                'Follow',
                                //style: bodySmallTextStyle,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: !alreadyFollowing,
                            child: ElevatedButton(
                              onPressed: () { leaveFollowing(); },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(200, 32.5)),
                                backgroundColor: MaterialStateProperty.all(AppColors.primary),
                                elevation: MaterialStateProperty.all(10),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                              ),
                              child: Text(
                                'Following',
                                //style: bodySmallTextStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(),
                  ],
                ),*/
