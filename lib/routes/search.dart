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

class Search extends StatefulWidget {
  const Search({Key, key, required this.analytics, required this.observer})
      : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  String currentUsername = "";
  List<AppUser> users = [];
  List<Post> allposts = [];
  List<Post> posts = [];

  bool isUserClicked = false;
  late AppUser dummy;
  final textFieldFocusNode = FocusNode();
  String searchText = '';

  late List<dynamic> postsRaw;
  late List<dynamic> myFollowersRaw;
  late List<String> myFollowers = [];

  Future<void> search() async {
    users.clear();
    allposts.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        currentUsername = documentSnapshot['username'];
        myFollowersRaw = documentSnapshot['userFollowers'];
      });
    });
    for (var i in myFollowersRaw) {
      myFollowers.add(i.toString());
    }
    if (searchText == '') {

    } else {
      FirebaseFirestore.instance
          .collection('users')
          //.where('isDeactivated', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          //print(doc["username"]);
          if (doc["username"] != currentUsername &&
              doc["username"].contains(searchText)) {
            setState(() {
              print("AAAAASDSADSA");
              users.add(AppUser.fromMap(doc.data()));
              print(users);
            });
          }
          /*print(searchText);
          print("asdasdasdasd");
          print(users);*/
          //print(doc);
        });
      });
    }
    await FirebaseFirestore.instance
        .collection('users')
        .where('isDeactivated', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["isPrivate"] == false) {
          postsRaw = doc["usersPosts"];
          for (var e in postsRaw) {
            allposts.add(Post.fromMap(e));
          }
        }
      });
    });

    //print("Posts: $posts");
    posts.clear();
    //print("AllPosts: $allposts");

    if (searchText != '') {
      for (var i in allposts) {
        if (i.description.contains(searchText)) {
          print("CONTAINTS");
          setState(() {
            posts.add(i);
            print(posts);
          });
        }
      }
    } else {
      /*
      for (var i in allposts) {
        setState(() {posts.add(i);});
      }

       */
    }
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;



  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Search', 'SearchState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              'SUmate',
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
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        color: AppColors.background,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 350,
                    child: TextField(
                      onChanged: (String value) {
                        searchText = value;
                      },
                      focusNode: textFieldFocusNode,
                      //style: bodySmallTextStyle,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(20)),
                        ),
                        /*enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9885B1))),*/
                        labelText: 'Search',
                        //labelStyle: bodySmallTextStyle,
                        suffixIcon: IconButton(
                          onPressed: () {
                            textFieldFocusNode.unfocus();
                            search();
                            setState(() {});
                          },
                          splashRadius: 55,
                          icon: Icon(
                              IconData(0xf1ad, fontFamily: 'MaterialIcons'),
                              color: AppColors.textColor),
                          iconSize: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              //width: 350,
              height: 450,
              child: PageView(
                controller: PageController(initialPage: 0),
                scrollDirection: Axis.horizontal,
                children: [
                  usersSection(users),
                  postsSection(posts),
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
              onPressed: () {Navigator.pushNamed(
                  context, '/feed');},
              splashRadius: 30,
              icon: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
              iconSize: 45,
            ),

            SizedBox(width: 50,),

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

Widget usersSection(List<AppUser> users) {
  return Container(
    //width: 350,
    height: 420,
    child: ListView(
      padding: EdgeInsets.all(0.0),
      children: users.map((each) => UsersSection(user: each)).toList(),
    ),
  );
}

Widget postsSection(List<Post> posts) {
  return Container(
    //width: 350,
    height: 420,
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
  );
}
