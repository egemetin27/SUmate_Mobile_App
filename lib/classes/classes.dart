class AppUser {
  late String username = "";
  late String password = "";
  late String email = "";
  late String phoneNumber = "";
  late int postCount;
  late int followersCount;
  late int followingCount;
  late String bio;
  late List<dynamic> usersPosts;
  late List<dynamic> userFollowers;
  late List<dynamic> userFollowing;
  late List<dynamic> userNotifications;
  late List<dynamic> usersChats;
  late bool isPrivate;
  late bool isDeactivated;
  late String profilePhoto;
  late String profilePhotoUrl;
  AppUser({ required this.username, required this.password, required this.email, required this.phoneNumber, required this.postCount, required this.followersCount, required this.followingCount, required this.bio, required this.isPrivate, required this.isDeactivated, required this.profilePhoto, required this.profilePhotoUrl });
  AppUser.fromMap(var map){
    username = map['username'] ?? "--";
    email = map['email'] ?? "--";
    phoneNumber = "";
    password = map['password'] ?? "--";
    postCount = map['postCount'] ?? 0;
    followersCount = map['followersCount'] ?? 0;
    followingCount = map['followingCount'] ?? 0;
    bio = map['bio'] ?? "--";
    usersPosts = map["userPosts"] ?? [];
    userNotifications = map['userNotifications'] ?? [];
    userFollowers = map['userFollowers'] ?? [];
    userFollowing = map['userFollowing'] ?? [];
    usersChats = map['usersChats'] ?? [];
    isPrivate = map['isPrivate'] ?? false;
    isDeactivated = map['isDeactivated'] ?? false;
    profilePhoto = map['profilePhoto'] ?? "-";
    profilePhotoUrl = map['profilePhotoUrl'] ?? "-";
  }
}

class Post {
  late String imagePath;
  late String imageUrl;
  late String userPhotoUrl;
  late String description;
  late int likes;
  late int dislikes;
  late int reports;
  late List<dynamic> comments;
  late List<dynamic> likeUsersID;
  late List<dynamic> dislikeUsersID;
  late List<dynamic> reportUsersID;
  late List<dynamic> commentUsersID;
  Post({ required this.imagePath, required this.description, required this.likes, required this.dislikes, required this.reports, required this.userPhotoUrl, required this.imageUrl});

  Post.fromMap(Map map){
    imageUrl = map['imageUrl'];
    userPhotoUrl = map['userPhotoUrl'];
    imagePath = map['imagePath'];
    description = map['description'];
    likes = map['likes'];
    dislikes = map['dislikes'];
    reports = map['reports'];
    commentUsersID = [];
    for (var i in map['commentUsersID']) {
      commentUsersID.add(i.toString());
    }
    comments = [];
    for (var i in map['comments']) {
      comments.add(i.toString());
    }
    likeUsersID = [];
    for (var i in map['likeUsersID']) {
      likeUsersID.add(i.toString());
    }
    dislikeUsersID = [];
    for (var i in map['dislikeUsersID']) {
      dislikeUsersID.add(i.toString());
    }
    reportUsersID = [];
    for (var i in map['reportUserID']) {
      reportUsersID.add(i.toString());
    }
  }
}

class Notificat {
  late String userID;
  late String message;
  Notificat({ required this.userID, required this.message });
  Notificat.fromMap(Map map){
    userID = map['userID'];
    message = map['message'];
  }
}

class ChatType {
  late String msg;
  late String type;
  ChatType({ required this.msg, required this.type });
}

class Chat {
  late AppUser user;
  late List<ChatType> chatbox;
  Chat({ required this.user, required this.chatbox });
  Chat.fromMap(Map map){
    user = map['user'];
    chatbox = map['chatbox'];
  }
}