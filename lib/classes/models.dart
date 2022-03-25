import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' show get;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sumate_mobile_app/routes/profile.dart';

class PostsOwnSection extends StatefulWidget {
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

  final Post post;
  final Function like;
  final Function dislike;
  final Function share;
  final Function makeComment;
  final Function delete;

  PostsOwnSection(
      {required this.post,
      required this.like,
      required this.dislike,
      required this.share,
      required this.makeComment,
      required this.delete});

  @override
  _PostsOwnSectionState createState() => _PostsOwnSectionState();
}

class _PostsOwnSectionState extends State<PostsOwnSection> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  late String currUsername;

  List<dynamic> postsRaw = [];

  List<Post> posts = [];

  List<String> postsUsers = [];

  bool liked = false;
  bool disliked = false;

  late String thatUser;

  late Post thatPost;

  void addLike() async {
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

    posts.clear();
    for (var e in postsRaw) {
      posts.add(Post.fromMap(e));
    }
    for (var e in posts) {
      if (e.imagePath == widget.post.imagePath) {
        thatUser = postsUsers[posts.indexOf(e)];
        thatPost = e;
        break;
      }
    }

    postsRaw.clear();
    postsUsers.clear();
    posts.clear();
    if (widget.post.likeUsersID.contains(firebaseUser!.uid)) {
      widget.post.likes--;
      liked = false;
      widget.post.likeUsersID.remove(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts': FieldValue.arrayRemove([PostsOwnSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOwnSection.toMap(widget.post)])
      });
    } else {
      widget.post.likes++;
      liked = true;
      widget.post.likeUsersID.add(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts': FieldValue.arrayRemove([PostsOwnSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOwnSection.toMap(widget.post)])
      });
    }
    setState(() {});
  }

  void addDislike() async {
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
      if (e.imagePath == widget.post.imagePath) {
        thatUser = postsUsers[posts.indexOf(e)];
        thatPost = e;
        break;
      }
    }

    postsRaw.clear();
    postsUsers.clear();
    posts.clear();

    if (widget.post.dislikeUsersID.contains(firebaseUser!.uid)) {
      widget.post.dislikes--;
      disliked = false;
      widget.post.dislikeUsersID.remove(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts': FieldValue.arrayRemove([PostsOwnSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOwnSection.toMap(widget.post)])
      });
    } else {
      widget.post.dislikes++;
      disliked = true;
      widget.post.dislikeUsersID.add(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts': FieldValue.arrayRemove([PostsOwnSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOwnSection.toMap(widget.post)])
      });
    }
    setState(() {});
  }

  createAlertDialogForDelete(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Deleting Post'),
            content: Text('Are you sure you want to delete this post?'),
            actions: <Widget>[
              MaterialButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    deletePost();
                    Navigator.pushNamed(context, '/profile');
                  }),
              MaterialButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  void deletePost() async {
    firebase_storage.FirebaseStorage.instance
        .refFromURL(
            'gs://cs310-term-project.appspot.com' + widget.post.imagePath)
        .delete();

    userCollection.doc(firebaseUser!.uid).update({
      'usersPosts':
          FieldValue.arrayRemove([PostsOwnSection.toMap(widget.post)]),
    });
    userCollection.doc(firebaseUser!.uid).update({
      'postCount': FieldValue.increment(-1),
    });
  }

  late String filename;
  late List<String> filenameParts;
  void resharePost() async {
    var response = await get(Uri.parse(widget.post.imageUrl));
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";

    filename = generateRandomString(55) + ".jpg";

    var filePathAndName = documentDirectory.path + '/images/' + filename;
    await Directory(firstPath).create(recursive: true);
    File file2 = new File(filePathAndName);
    file2.writeAsBytesSync(response.bodyBytes);
    //print(file2);
    Navigator.pushNamed(context, '/creatingPost',
        arguments: {"image": file2, "filename": filename});
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
        width: 325,
        height: 265,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: widget.post.userPhotoUrl == ''
                  ? NetworkImage(
                      "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                  : NetworkImage(widget.post.userPhotoUrl),
              backgroundColor: Colors.green,
              radius: 17.5,
            ),
            SizedBox(width: 5),
            Column(
              children: <Widget>[
                Container(
                  //color: Colors.green,
                  width: 275,
                  height: 175,
                  child: Image.network(widget.post.imageUrl, fit: BoxFit.fill),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: addLike,
                      splashRadius: 10,
                      icon: Icon(IconData(0xe65b, fontFamily: 'MaterialIcons'),
                          color: liked == true
                              ? AppColors.secondary
                              : AppColors.textColor,
                          size: 15),
                      //iconSize: 15,
                    ),
                    Container(
                      height: 25,
                      width: 30,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.post.likes.toString(),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: addDislike,
                      splashRadius: 10,
                      icon: Icon(IconData(0xe658, fontFamily: 'MaterialIcons'),
                          color: disliked == true
                              ? Colors.red
                              : AppColors.textColor,
                          size: 15),
                      //iconSize: 15,
                    ),
                    Container(
                      height: 25,
                      width: 30,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.post.dislikes.toString(),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: resharePost,
                      splashRadius: 10,
                      icon: Icon(Icons.share,
                          color: AppColors.textColor, size: 15),
                      //iconSize: 15,
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: (() {
                        Navigator.pushNamed(context, '/comment',
                            arguments: {'post': widget.post});
                      }),
                      splashRadius: 10,
                      icon: Icon(Icons.edit,
                          color: AppColors.textColor, size: 15),
                      //iconSize: 15,
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: (() async {
                        await createAlertDialogForDelete(context);
                      }),
                      splashRadius: 10,
                      icon: Icon(Icons.cancel,
                          color: AppColors.textColor, size: 15),
                      //iconSize: 15,
                    ),
                  ],
                ),
                Container(
                  child: Text(
                    widget.post.description,
                  ),
                  //color: Colors.green,
                  width: 275,
                  height: 45,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostsOthersSection extends StatefulWidget {
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

  final Post post;
  final Function like;
  final Function dislike;
  final Function share;
  final Function makeComment;
  final Function bookmark;
  PostsOthersSection(
      {required this.post,
      required this.like,
      required this.dislike,
      required this.share,
      required this.makeComment,
      required this.bookmark});

  @override
  _PostsOthersSectionState createState() => _PostsOthersSectionState();
}

class _PostsOthersSectionState extends State<PostsOthersSection> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  late String currUsername;

  List<dynamic> postsRaw = [];

  bool liked = false;
  bool disliked = false;

  List<Post> posts = [];

  List<String> postsUsers = [];

  late String thatUser;

  late Post thatPost;

  late String userID;

  Future<void> getUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        //.where('isDeactivated', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        for (var i in doc["usersPosts"]) {
          if (i["imageUrl"] == widget.post.imageUrl) {
            setState(() {
              user = AppUser.fromMap(doc.data());
              userID = doc.id;
            });
            return;
          }
        }
      });
    });
  }

  static Map<String, dynamic> toMap(Notificat notifi) => {
    'userID': notifi.userID,
    'message': notifi.message,
  };

  late AppUser user = AppUser(
      username: "",
      password: "",
      email: "",
      phoneNumber: "",
      postCount: 0,
      followersCount: 0,
      followingCount: 0,
      bio: "",
      isPrivate: false,
      isDeactivated: false,
      profilePhoto: "",
      profilePhotoUrl: "");

  void addLike() async {
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

    posts.clear();
    for (var e in postsRaw) {
      posts.add(Post.fromMap(e));
    }
    for (var e in posts) {
      if (e.imagePath == widget.post.imagePath) {
        thatUser = postsUsers[posts.indexOf(e)];
        thatPost = e;
        break;
      }
    }

    postsRaw.clear();
    postsUsers.clear();
    posts.clear();
    if (widget.post.likeUsersID.contains(firebaseUser!.uid)) {
      widget.post.likes--;
      liked = false;
      widget.post.likeUsersID.remove(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayRemove([PostsOthersSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOthersSection.toMap(widget.post)])
      });
    } else {
      widget.post.likes++;
      liked = true;
      widget.post.likeUsersID.add(firebaseUser!.uid);

      Notificat newRequest = Notificat(userID: firebaseUser!.uid, message: 'liked your post.');
      await userCollection.doc(userID).update({
        'userNotifications': FieldValue.arrayUnion([toMap(newRequest)])
      });

      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayRemove([PostsOthersSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOthersSection.toMap(widget.post)])
      });
    }
    setState(() {});
  }

  void addDislike() async {
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
      if (e.imagePath == widget.post.imagePath) {
        thatUser = postsUsers[posts.indexOf(e)];
        thatPost = e;
        break;
      }
    }

    postsRaw.clear();
    postsUsers.clear();
    posts.clear();

    if (widget.post.dislikeUsersID.contains(firebaseUser!.uid)) {
      widget.post.dislikes--;
      disliked = false;
      widget.post.dislikeUsersID.remove(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayRemove([PostsOthersSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOthersSection.toMap(widget.post)])
      });
    } else {
      widget.post.dislikes++;
      disliked = true;
      widget.post.dislikeUsersID.add(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayRemove([PostsOthersSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOthersSection.toMap(widget.post)])
      });
    }
    setState(() {});
  }

  void addReport() async {
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
      if (e.imagePath == widget.post.imagePath) {
        thatUser = postsUsers[posts.indexOf(e)];
        thatPost = e;
        break;
      }
    }
    postsRaw.clear();
    postsUsers.clear();
    posts.clear();

    if (widget.post.reportUsersID.contains(firebaseUser!.uid)) {
      SnackBar reportSnackBar =
          SnackBar(content: Text("User has been already reported by you!"));
      Scaffold.of(context).showSnackBar(reportSnackBar);
    } else {
      widget.post.reports++;
      widget.post.reportUsersID.add(firebaseUser!.uid);

      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayRemove([PostsOthersSection.toMap(thatPost)])
      });
      await userCollection.doc(thatUser).update({
        'usersPosts':
            FieldValue.arrayUnion([PostsOthersSection.toMap(widget.post)])
      });
      SnackBar reportSnackBar =
          SnackBar(content: Text("User has been reported."));
      Scaffold.of(context).showSnackBar(reportSnackBar);
    }
    setState(() {});
  }

  late String filename;
  late List<String> filenameParts;
  void resharePost() async {
    var response = await get(Uri.parse(widget.post.imageUrl));
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";

    filename = generateRandomString(55) + ".jpg";

    var filePathAndName = documentDirectory.path + '/images/' + filename;
    await Directory(firstPath).create(recursive: true);
    File file2 = new File(filePathAndName);
    file2.writeAsBytesSync(response.bodyBytes);
    //print(file2);
    Navigator.pushNamed(context, '/creatingPost',
        arguments: {"image": file2, "filename": filename});
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  late var desc;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
        width: MediaQuery.of(context).size.width * 20 / 21,
        //height: MediaQuery.of(context).size.height * 2/5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Material(
                    color: Colors.green,
                    child: InkWell(
                      child: CircleAvatar(
                        backgroundImage: widget.post.userPhotoUrl == ''
                            ? NetworkImage(
                                "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                            : NetworkImage(widget.post.userPhotoUrl),
                        backgroundColor: Colors.green,
                        radius: 27,
                      ),
                      onTap: () async {
                        await getUser();
                        Navigator.pushNamed(context, '/profileothers',
                            arguments: {
                              "imageUrl": widget.post.userPhotoUrl,
                              "user": user,
                            });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () async {
                    await getUser();
                    Navigator.pushNamed(context, '/profileothers', arguments: {
                      "imageUrl": widget.post.userPhotoUrl,
                      "user": user,
                    });
                  },
                  child: Container(
                    child: Text(
                      user.username,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    //color: Colors.green,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  //color: Colors.green,
                  width: MediaQuery.of(context).size.width * 19 / 20,
                  //height: 175,
                  child: Image.network(
                    widget.post.imageUrl == ''
                        ? "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png"
                        : widget.post.imageUrl,
                    fit: BoxFit.fill,
                  ),
                ),
                /*InkWell(
                      child: CircleAvatar(
                        backgroundImage: (widget.post.userPhotoUrl == ''
                            ? NetworkImage(
                            "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                            : NetworkImage(widget.post.userPhotoUrl)),
                        backgroundColor: Colors.green,
                        radius: 40,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/profileothers',
                            arguments: {
                              "imageUrl": widget.post.userPhotoUrl,
                              "username": widget.
                            });
                      },
                    ),*/
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: [
                          //SizedBox(width: 10,),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: addLike,
                            splashRadius: 10,
                            icon: Icon(
                                IconData(0xe65b, fontFamily: 'MaterialIcons'),
                                color: liked == true
                                    ? AppColors.secondary
                                    : Colors.black,
                                size: 22),
                            //iconSize: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 30,
                            width: 25,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.post.likes.toString(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: addDislike,
                            splashRadius: 10,
                            icon: Icon(
                                IconData(0xe658, fontFamily: 'MaterialIcons'),
                                color: disliked == true
                                    ? Colors.red
                                    : Colors.black,
                                size: 22),
                            //iconSize: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 25,
                            width: 30,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.post.dislikes.toString(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: (() {
                          Navigator.pushNamed(context, '/comment',
                              arguments: {'post': widget.post});
                        }),
                        splashRadius: 10,
                        icon: Icon(Icons.comment,
                            color: AppColors.textColor, size: 22),
                        //iconSize: 15,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: resharePost,
                        splashRadius: 10,
                        icon: Icon(Icons.share,
                            color: AppColors.textColor, size: 22),
                        //iconSize: 15,
                      ),

                      //SizedBox(width: 90),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: addReport,
                        splashRadius: 10,
                        icon: Icon(Icons.report,
                            color: AppColors.textColor, size: 22),
                        //iconSize: 15,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: desc = new RichText(
                    text: new TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      style: new TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                            text: user.username + " ",
                            style: new TextStyle(fontWeight: FontWeight.w900)),
                        new TextSpan(text: widget.post.description),
                      ],
                    ),
                  ),
                  //color: Colors.green,
                  width: MediaQuery.of(context).size.width * 18 / 20,
                  height: 45,
                ),
                /*Container(
                      child: Text(
                        widget.post.description,
                      ),
                      //color: Colors.green,
                      width: MediaQuery.of(context).size.width * 18/20,
                      height: 45,
                    ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSection extends StatefulWidget {
  static Map<String, dynamic> toMap(Notificat notifi) => {
        'userID': notifi.userID,
        'message': notifi.message,
      };

  final Notificat currNotification;
  NotificationSection({required this.currNotification});

  @override
  _NotificationSectionState createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  Future<void> updatePage() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currNotification.userID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      user = AppUser.fromMap(documentSnapshot.data());
      username = documentSnapshot['username'];
      photoUrl = documentSnapshot['profilePhotoUrl'];
    });
    setState(() {});
  }

  String username = '', photoUrl = '';
  late AppUser user;
  late String thatUsername;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  late String followingUsersAccount;

  Future<void> approve() async {
    followingUsersAccount = widget.currNotification.userID;
    userCollection.doc(firebaseUser!.uid).update({
      'userFollowers': FieldValue.arrayUnion([followingUsersAccount])
    });
    userCollection
        .doc(firebaseUser!.uid)
        .update({'followersCount': FieldValue.increment(1)});
    userCollection.doc(followingUsersAccount).update({
      'userFollowing': FieldValue.arrayUnion([firebaseUser!.uid])
    });
    userCollection
        .doc(followingUsersAccount)
        .update({'followingCount': FieldValue.increment(1)});
    await userCollection.doc(firebaseUser!.uid).update({
      'userNotifications': FieldValue.arrayRemove(
          [NotificationSection.toMap(widget.currNotification)])
    });
    setState(() {});
  }

  Future<void> decline() async {
    await userCollection.doc(firebaseUser!.uid).update({
      'userNotifications': FieldValue.arrayRemove(
          [NotificationSection.toMap(widget.currNotification)])
    });
    setState(() {});
  }

  @override
  void initState() {
    updatePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        leading: ClipOval(
          child: Material(
            child: InkWell(
              child: CircleAvatar(
                backgroundImage: (photoUrl == ''
                    ? NetworkImage(
                        "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                    : NetworkImage(photoUrl)),
                backgroundColor: Colors.green,
                radius: 30,
              ),
              onTap: () {
                Navigator.pushNamed(context, '/profileothers',
                    arguments: {"imageUrl": photoUrl, "user": user});
              },
            ),
          ),
        ),
        title: Text(
          username,
        ),
        subtitle: Text(
          '${widget.currNotification.message}',
        ),
        trailing: widget.currNotification.message == "wants to follow you." ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
              IconButton(
                onPressed: (() async {
                  await approve();
                  Navigator.pushNamed(context, '/notifications');
                }),
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 45,
                ),
              ),
              IconButton(
                onPressed: (() async {
                  await decline();
                  Navigator.pushNamed(context, '/notifications');
                }),
                icon: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 45,
                ),
              ),
          ],
        ) : null,
      ),
    );
  }
}

class UsersSection extends StatelessWidget {
  final AppUser user;
  UsersSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: AppColors.background,
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
            width: 325,
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/profileothers',
                        arguments: {'user': user});
                  },
                  child: Container(
                    child: CircleAvatar(
                      backgroundImage: (user.profilePhotoUrl == ''
                          ? NetworkImage(
                              "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                          : NetworkImage(user.profilePhotoUrl)),
                      backgroundColor: Colors.green,
                    ),
                    width: 65,
                    height: 65,
                  ),
                ),
                SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/profileothers',
                        arguments: {'user': user});
                  },
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                    //color: Colors.green,
                    width: 245,
                    height: 65,
                    child: Text(
                      user.username,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Divider(
          height: 8,
          color: Colors.grey,
        ),
      ],
    );
  }
}

class UsersMessagesSection extends StatelessWidget {
  final AppUser user;
  UsersMessagesSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 8, 0, 0),
        width: 325,
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/messagesprivate', arguments: {'user': user});
              },
              child: Container(
                child: CircleAvatar(
                  backgroundImage: (user.profilePhotoUrl == ''
                      ? NetworkImage(
                          "https://lunapolis.ee/wp-content/uploads/2019/08/Empty-Profile-Picture-450x450-transparent.png")
                      : NetworkImage(user.profilePhotoUrl)),
                  backgroundColor: Colors.green,
                ),
                width: 65,
                height: 65,
              ),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/messagesprivate');
              },
              splashColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                //color: Colors.green,
                width: 245,
                height: 65,
                child: Text(
                  '${user.username}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyMessages extends StatelessWidget {
  final AppUser user;
  final String msg;
  MyMessages({required this.user, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
        width: 325,
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.green,
              width: 65,
              height: 65,
            ),
            SizedBox(width: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              //color: Colors.green,
              width: 245,
              height: 65,
              child: Text(
                '$msg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YourMessages extends StatelessWidget {
  final String msg;
  YourMessages({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
        width: 325,
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              //color: Colors.green,
              width: 245,
              height: 65,
              child: Text(
                '$msg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final String msg;
  final String type;
  Messages({required this.msg, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
        width: 325,
        height: 75,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          //color: Colors.green,
          width: 245,
          height: 65,
          child: Align(
            alignment:
                (type == "receiver" ? Alignment.topLeft : Alignment.topRight),
            child: Container(
              child: Text(
                '$msg',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
