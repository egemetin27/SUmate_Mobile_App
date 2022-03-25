import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  final String uid;
  Database({required this.uid});

  Future<void> addUserAutoID(String mail, String name, String surname, String username) async {
    userCollection.add({
      'name': name,
      'surname': surname,
      //'userToken': token,
      'email': mail,
      'username': username,   // the same as email
      'phoneNumber': "",
      'postCount': 0,
      'followersCount': 0,
      'followingCount': 0,
      'bio': '',
      'usersPosts': [],
      'userFollowers': [],
      'userNotifications': [],
      'userFollowing': [],
      'usersChats': [],
      'isPrivate': false,
      'isDeactivated': false,
      'profilePhoto': '',
      'profilePhotoUrl': '',
    })
        .then((value) => print('User added'))
        .catchError((error) => print('Error: ${error.toString()}'));
  }

  Future addUser(String mail, String name, String surname, String username) async {
    userCollection.doc(uid).set({
      'name': name,
      'surname': surname,
      //'userToken': token,
      'email': mail,
      'username': username,   // the same as email
      'phoneNumber': "",
      'postCount': 0,
      'followersCount': 0,
      'followingCount': 0,
      'bio': '',
      'usersPosts': [],
      'userFollowers': [],
      'userNotifications': [],
      'userFollowing': [],
      'usersChats': [],
      'isPrivate': false,
      'isDeactivated': false,
      'profilePhoto': '',
      'profilePhotoUrl': '',
    });
  }
}