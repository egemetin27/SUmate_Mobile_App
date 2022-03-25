import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services//analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:sumate_mobile_app/classes/models.dart';

class DirectMessagesPrivate extends StatefulWidget {
  const DirectMessagesPrivate({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _DirectMessagesPrivateState createState() => _DirectMessagesPrivateState();
}

class _DirectMessagesPrivateState extends State<DirectMessagesPrivate> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  AppUser dummyUser = AppUser(username: 'username #1', email: '', password: '', postCount: 0, followersCount: 0, followingCount: 0, bio: 'desc #1', isPrivate: true, profilePhoto: '', isDeactivated: false, profilePhotoUrl: '', phoneNumber: '', );
  List<ChatType> chatboxes = [
    ChatType(msg: "a1", type: "sender"),
    ChatType(msg: "b1", type: "receiver"),
    ChatType(msg: "a2", type: "sender"),
    ChatType(msg: "a3", type: "sender"),
    ChatType(msg: "b2", type: "receiver"),
  ];

  late Chat dummyChat;
  late String lastMsg;
  final textFieldFocusNode = FocusNode();
  var _controller = TextEditingController();

  static Map<String, dynamic> toMap(Chat ch) => {
    'user': ch.user,
    'chatbox': ch.chatbox,
  };

  setLastText(String msg){
    if (msg != null && msg != ""){
      lastMsg = msg;
    }
  }
  getLastText(){
    return lastMsg;
  }
  //List<dynamic> x = Chat(user: user, chatbox: chatboxes);
  addNewChat(String msg) {
    if (msg != null && msg != "") {
      chatboxes.add(ChatType(msg: "$msg", type: "sender"));
      /*userCollection.doc(firebaseUser!.uid).update({
        'usersChats': FieldValue.arrayUnion([toMap(dummyChat)])
      });*/
    }
  }
  late AppUser user;
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  late Map<dynamic, dynamic> elements;


  @override
  void initState(){
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'DirectMessagesPrivate', 'DirectMessagesPrivateState');
  }

  @override
  Widget build(BuildContext context) {
    elements = ModalRoute.of(context)!.settings.arguments as Map;
    user = elements['user'];
    dummyChat = Chat(user: user, chatbox: chatboxes);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${user.username}',
          //style: mainTitleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.background,
              //height: 600,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 530,
                      child: ListView(
                        padding: EdgeInsets.all(0.0),
                        children: dummyChat.chatbox.map(
                                (chat) => Messages(
                              msg: chat.msg,
                              type: chat.type,
                            )
                        ).toList(),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: MediaQuery.of(context).size.width * 11/12,
                      child: TextField(
                        controller: _controller,
                        focusNode: textFieldFocusNode,
                        onChanged: (String value) => setLastText(value),
                        //style: bodySmallTextStyle,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: Color(0xFF9885B1))
                          ),
                          //labelStyle: bodySmallTextStyle,
                          suffixIcon: TextButton(
                            onPressed: () { textFieldFocusNode.unfocus(); addNewChat(getLastText()); _controller.clear(); },
                            //splashRadius: 55,
                            child: Text("Send"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2,)
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