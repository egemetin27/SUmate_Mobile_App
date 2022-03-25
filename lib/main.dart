import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumate_mobile_app/routes/comment.dart';
import 'package:sumate_mobile_app/routes/contacts.dart';
import 'package:sumate_mobile_app/routes/createPostView.dart';
import 'package:sumate_mobile_app/routes/creatingPost.dart';
import 'package:sumate_mobile_app/routes/deactivateaccount.dart';
import 'package:sumate_mobile_app/routes/deleteaccount.dart';
import 'package:sumate_mobile_app/routes/feed.dart';
import 'package:sumate_mobile_app/routes/followers.dart';
import 'package:sumate_mobile_app/routes/followings.dart';
import 'package:sumate_mobile_app/routes/messages.dart';
import 'package:sumate_mobile_app/routes/messages_private.dart';
import 'package:sumate_mobile_app/routes/notifications.dart';
import 'package:sumate_mobile_app/routes/photozoom.dart';
import 'package:sumate_mobile_app/routes/profile.dart';
import 'package:sumate_mobile_app/routes/profileSettings.dart';
import 'package:sumate_mobile_app/routes/profile_others.dart';
import 'package:sumate_mobile_app/routes/search.dart';
import 'package:sumate_mobile_app/routes/settings.dart';
import 'package:sumate_mobile_app/routes/welcome.dart';
import 'package:sumate_mobile_app/routes/login.dart';
import 'package:sumate_mobile_app/routes/signup.dart';
import 'package:sumate_mobile_app/routes/walkthrough.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sumate_mobile_app/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
              home: Scaffold(
                body: Center(
                  child:
                  Text("No Firebase Connection ${snapshot.error.toString()}"),
            ),
          ));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print('Firebase connected');
          return AppBase();
        }
        return MaterialApp(
          home: Center(child: Text("...")),
        );
      },
    );
  }
}

class AppBase extends StatefulWidget {
  const AppBase({Key, key}) : super(key: key);


  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  static FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  State<AppBase> createState() => _AppBaseState();
}

class _AppBaseState extends State<AppBase> {


  static bool hasPassedWalkthrough = false;
  loadWalkthroughStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasPassedWalkthrough = prefs.getBool('status')!; }
    );
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadWalkthroughStatus();
    return StreamProvider<User?>.value(
        value: AuthService().user,
        initialData: null,
        child: MaterialApp(
          navigatorObservers: <NavigatorObserver>[AppBase.observer],
          initialRoute: hasPassedWalkthrough == false ? '/walk-through':'/welcome',
          //home: Walkthrough(analytics: analytics, observer: observer),
          routes: {
            '/welcome': (context) => Welcome(analytics: AppBase.analytics, observer: AppBase.observer),
            '/login': (context) => Login(analytics: AppBase.analytics, observer: AppBase.observer),
            '/signup': (context) => SignUp(analytics: AppBase.analytics, observer: AppBase.observer),
            '/walk-through': (context) => Walkthrough(analytics: AppBase.analytics, observer: AppBase.observer),
            '/feed': (context) => Feed(analytics: AppBase.analytics, observer: AppBase.observer),
            '/search': (context) => Search(analytics: AppBase.analytics, observer: AppBase.observer),
            '/profile': (context) => Profile(analytics: AppBase.analytics, observer: AppBase.observer),
            '/profilesettings': (context) => ProfileSettings(analytics: AppBase.analytics, observer: AppBase.observer),
            //'/profileothers': (context) => ProfileOthers(analytics: analytics, observer: observer),
            '/messages': (context) => DirectMessagesPublic(analytics: AppBase.analytics, observer: AppBase.observer),
            '/messagesprivate': (context) => DirectMessagesPrivate(analytics: AppBase.analytics, observer: AppBase.observer),
            '/createPostView': (context) => createPostView(analytics: AppBase.analytics, observer: AppBase.observer),
            '/creatingPost': (context) => creatingPost(analytics: AppBase.analytics, observer: AppBase.observer),
            '/settings': (context) => SettingsAll(analytics: AppBase.analytics, observer: AppBase.observer),
            '/deactivateaccount': (context) => DeactivateAccount(analytics: AppBase.analytics, observer: AppBase.observer),
            '/deleteaccount': (context) => DeleteAccount(analytics: AppBase.analytics, observer: AppBase.observer),
            '/notifications': (context) => Notifications(analytics: AppBase.analytics, observer: AppBase.observer),
            '/comment': (context) => Comment(analytics: AppBase.analytics, observer: AppBase.observer),
            '/following': (context) => Following(analytics: AppBase.analytics, observer: AppBase.observer),
            '/followers': (context) => Followers(analytics: AppBase.analytics, observer: AppBase.observer),
            '/profileothers': (context) => ProfileOthers(analytics: AppBase.analytics, observer: AppBase.observer),
            '/contacts': (context) => Contacts(analytics: AppBase.analytics, observer: AppBase.observer),
            '/photozoom': (context) => ZoomedPhoto(analytics: AppBase.analytics, observer: AppBase.observer),
          },
        )
    );
  }
}
