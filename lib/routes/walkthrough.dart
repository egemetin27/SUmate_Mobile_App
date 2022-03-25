import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumate_mobile_app/routes/welcome.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';

class Walkthrough extends StatefulWidget {
  const Walkthrough({Key, key, required this.analytics, required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _WalkthroughState createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  PageController pc = PageController(initialPage: 0);
  int currentPage = 1;
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  bool hasPassedWalkthrough = false;

  setWalkthroughStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('status', true);
  }

  loadWalkthroughStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasPassedWalkthrough = prefs.getBool('status')!; }
    );
  }

  void prevPage() {
    if (currentPage != 1) {
      pc.previousPage(duration: Duration(seconds: 1), curve: Curves.easeInOut);
      currentPage--;
    }
  }

  void nextPage() {
    pc.nextPage(duration: Duration(seconds: 1), curve: Curves.easeInOut);
    currentPage++;
  }

  Widget page1() {
    return Scaffold(
      body: Container(
        color: Color(0xffFCD5B1),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 11 / 13,
                child: Image.asset('assets/images/signup.png')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                OutlinedButton(
                  onPressed: nextPage,
                  child: Text(
                    "Next", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget page2() {
    return Scaffold(
      body: Container(
        color: Color(0xffFCD5B1),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 11 / 13,
                child: Image.asset('assets/images/main.png')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: prevPage,
                  child: Text(
                    "Prev", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                OutlinedButton(
                  onPressed: nextPage,
                  child: Text(
                    "Next", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget page3() {
    return Scaffold(
      body: Container(
        color: Color(0xffFCD5B1),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 11 / 13,
                child: new Image.asset('assets/images/mate.png')),//Image.network("https://i.ibb.co/kKdrnpS/Screenshot-2021-11-21-204303.png")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: prevPage,
                  child: Text(
                    "Prev", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                OutlinedButton(
                  onPressed: nextPage,
                  child: Text(
                    "Next", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget page4() {
    return Scaffold(
      body: Container(
        color: Color(0xffFCD5B1),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 11 / 13,
                child: new Image.asset('assets/images/profile.png')),//Image.network("https://i.ibb.co/kKdrnpS/Screenshot-2021-11-21-204303.png")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: prevPage,
                  child: Text(
                    "Prev", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                OutlinedButton(
                  onPressed: () {
                    setWalkthroughStatus();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/welcome");
                  },
                  child: Text(
                    "Start!", style: TextStyle(color: AppColors.buttonText),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.clicking_box),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Walkthrough', 'WalkthroughState');
    loadWalkthroughStatus();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
    return Scaffold(
        body: PageView(
          controller: pc,
          children: [
            page1(),
            page2(),
            page3(),
            page4(),
          ],
        ));
    }
    else {
      return Welcome(analytics: widget.analytics, observer: widget.observer);
    }
  }
}
