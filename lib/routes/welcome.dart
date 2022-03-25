import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumate_mobile_app/routes/feed.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';


class Welcome extends StatefulWidget {
  const Welcome({Key, key, required this.analytics, required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  bool isPassed = false;
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  loadPassWalkthroughStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isPassed = prefs.getBool('status')!; }
    );
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Welcome', 'WelcomeState');
    loadPassWalkthroughStatus();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.W_background,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      "https://upload.wikimedia.org/wikipedia/tr/d/d3/Sabanc%C4%B1_%C3%9Cniversitesi_logosu.jpg",
                      width: 200,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 475,
                  ),
                  Container(
                    width: 250,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 8, color: AppColors.headingColor),
                      shape: BoxShape.circle,
                      boxShadow: [
                        new BoxShadow(
                            color: Color(0xFF5270DE),
                            blurRadius: 100.0,
                            spreadRadius: 20.0
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "SUmate",
                          style: WelcomeText,
                        ),
                      ],
                    ),

                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.clicking_box),
                        elevation: MaterialStateProperty.all(20),
                        shadowColor: MaterialStateProperty.all<Color>(
                            AppColors.clicking_box),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11.0),
                            )
                        ),
                      ),
                      child: Text(
                        " Login ",
                        style: buttonText,
                      )

                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      /*style: ElevatedButton.styleFrom (
                        primary: AppColors.clicking_box,
                        onPrimary: AppColors.clickedbuttonColor,
                        shadowColor: Colors.black,
                        elevation: 5,
                          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                      ),*/
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.clicking_box),
                        elevation: MaterialStateProperty.all(20),
                        shadowColor: MaterialStateProperty.all<Color>(
                            AppColors.clicking_box),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11.0),
                            )
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: buttonText,
                      )),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              // height: 125,
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.network(
                    "https://img-s2.onedio.com/id-60e75235f8d859493a1b5511/rev-0/w-1200/h-442/f-jpg/s-cbd31b97e56d38b14b83ce93a20c1e6e10437371.jpg",
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ),*/
            ],
          ),
        ),
      );
    }
    else {
      return Feed(analytics: widget.analytics, observer: widget.observer);
    }
  }
}
