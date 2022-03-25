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

class Comment extends StatefulWidget {
  const Comment({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {


  List<dynamic> commentList = [], commentUsersIDList = [];
  String comment = '';
  createAlertDialog(BuildContext context)
  {
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('Add Comment'),
        content: TextFormField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black26,
                  )
              ),
              hintText: 'Your comment...'
          ),
          onChanged: (String value) {
            comment = value;
          },
        ),
        actions:<Widget> [
          MaterialButton(child:Text('Add'),
              onPressed: (){ addComment(); Navigator.of(context).pop(); }),
          MaterialButton(child:Text('Cancel'),
              onPressed: (){ Navigator.of(context).pop(); })
        ],
      );
    }
    );
  }

  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  late String thatUser;
  late Map<dynamic, dynamic> elements;
  late Post post;
  late String currUsername;
  List<String> postsUsers = [];
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> addComment() async {
    if (comment != '') {
      await userCollection.doc(firebaseUser!.uid).get().then(
              (DocumentSnapshot documentSnapshot) {
            currUsername = documentSnapshot['username'];
          }
      );
      setState(() {
        commentList.add(comment);
        commentUsersIDList.add(currUsername);
      });

      await FirebaseFirestore.instance
          .collection('users')
          .where('isDeactivated', isEqualTo: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          for (var i in doc["usersPosts"]) {
            postsRaw.add(i);
            postsUsers.add(doc.id);
          }
        });
      });

      for (var e in postsRaw) {
        posts.add(Post.fromMap(e));
      }
      for (var e in posts) {
        if (e.imagePath == post.imagePath) {
          thatUser = postsUsers[posts.indexOf(e)];
          posts.remove(e);

          await userCollection.doc(thatUser).update({'usersPosts': FieldValue.arrayRemove([toMap(e)])});
          await userCollection.doc(thatUser).update({'usersPosts': FieldValue.arrayUnion([toMap(post)])});
          break;
        }
      }

    }
  }

  static Map<String, dynamic> toMap(Post post) => {
    'imageUrl': post.imageUrl,
    'userPhotoUrl': post.userPhotoUrl,
    'imagePath': post.imagePath,
    'description': post.description,
    'likes': post.likes,
    'dislikes': post.dislikes,
    'reports': post.reports,
    'commentUsersID': post.commentUsersID,
    'comments': post.comments,
    'likeUsersID': post.likeUsersID,
    'dislikeUsersID': post.dislikeUsersID,
    'reportUserID': post.reportUsersID,
  };


  List<dynamic> postsRaw = [];
  List<Post> posts = [];
  late Post currPost;
  @override
  void initState() {
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'MakeComment', 'MakeCommentState');
    super.initState();
  }

  bool loading = true;

  @override
  void didChangeDependencies() {
    if (loading) {
      elements = ModalRoute.of(context)!.settings.arguments as Map;
      post = elements["post"];
      //print(post.comments);
      setState(() {
        commentList = post.comments;
        commentUsersIDList = post.commentUsersID;
      });
      loading = false;
    }
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          //style: mainTitleStyle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        itemCount: commentList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 55,
            child: Card(
              child: Column(
                children:<Widget> [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0,bottom: 8.0),
                    child: Row(
                      children:<Widget> [
                        SizedBox(width: 20),
                        Text(commentUsersIDList[index] + ': ' + commentList[index]),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ createAlertDialog(context);},
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
