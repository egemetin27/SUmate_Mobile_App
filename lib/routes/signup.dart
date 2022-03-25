import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sumate_mobile_app/routes/feed.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/auth.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:sumate_mobile_app/services/database.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key, key, required this.analytics, required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final AuthService _auth = AuthService();
  String _message = "";
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  Future<void> _setCurrentScreen() async {
    await widget;
  }

  void setmessage(String msg) {
    setState(() {
      _message = msg;
      print(msg);
    });
  }

  bool isEnteredToApp = false;
  bool userExists = false;
  String username = "";
  String name = "";
  String surname = "";
  String mail = "";
  //String phoneNumber = "";
  String pass = "";
  final _formKey = GlobalKey<FormState>();

  setEnteredToAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enteredToApp', true);
  }

  loadEnteredToAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState( () {
      isEnteredToApp = prefs.getBool('enteredToApp')!;
    }
    );
  }

  /*Future signInWithGoogle() async {
    _auth.googleSignIn();
    Navigator.pop(context);
    Navigator.pushNamed(context, "/feed");
  }*/
  User? _userFromFirebase(User? user) {
    return user ?? null;
  }

  Future googleSignUp() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      String mail = googleUser!.email;
      int idx = mail.indexOf('@');
      String username = mail.substring(0,idx);
      print(mail + "-> username: " + username);
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = result.user;
      Database(uid: user!.uid).addUser(mail, "", "", username);
      Navigator.pop(context);
      Navigator.pushNamed(context, "/feed");
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
    }
  }
  /*
  Future facebookSignUp() async {
    try {
        // Trigger the sign-in flow
        final LoginResult loginResult = await FacebookAuth.instance.login();

        String mail = loginResult.;
        int idx = mail.indexOf('@');
        String username = mail.substring(0,idx);
        print(mail + "-> username: " + username);

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Once signed in, return the UserCredential
        UserCredential result = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        User? user = result.user;
        Database(uid: user!.uid).addUser(mail, "", "", username);
        Navigator.pop(context);
        Navigator.pushNamed(context, "/feed");
        return _userFromFirebase(user);

    } catch (e) {
      print(e.toString());
    }

  }*/

  Future<void> _createUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc["email"] == mail) {
          userExists = true;
        }
      });
    });
    if (userExists) {
      setmessage('User registration failed. The user already exists!');
      userExists = false;
    } else {

      dynamic result = await _auth.signupWithMailAndPass(mail, name, surname, username, pass);

      if (result != null) {
        setEnteredToAppStatus();
        print("Registration successful.");
        Navigator.pop(context);
        Navigator.pushNamed(context, '/feed');
      } else {
        setmessage('User registration failed.');
      }
    }
  }


  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'SignUp', 'SignUpState');
    loadEnteredToAppStatus();
    userExists = false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.W_background,
        body: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 8, color: AppColors.headingColor),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "SUmate",
                              style: sumate_otherpages,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: InputDecoration(
                              fillColor: AppColors.writing_box,
                              filled: true,
                              hintText: 'E-mail',
                              //hintStyle: DefaultText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your e-mail';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'The e-mail address is not valid';
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              mail = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 4),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: InputDecoration(
                              fillColor: Color(0xFFe0a96d),
                              filled: true,
                              hintText: 'Username',
                              // hintStyle: DefaultText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              username = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 4),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: InputDecoration(
                              fillColor: AppColors.writing_box,
                              filled: true,
                              hintText: 'Password',
                              //hintStyle: DefaultText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            enableSuggestions: false,
                            autocorrect: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              pass = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 4),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: InputDecoration(
                              fillColor: AppColors.writing_box,
                              filled: true,
                              hintText: 'Name',
                              //hintStyle: DefaultText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'You cannot leave your name empty.';
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              name = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 4),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: InputDecoration(
                              fillColor: AppColors.writing_box,
                              filled: true,
                              hintText: 'Surname',
                              //hintStyle: DefaultText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'You cannot leave your surname empty.';
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              surname = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _createUser();
                          }
                        },
                        child: Text(
                          "Sign Up",
                          style: buttonText,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.clicking_box),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: AppColors.niceGray,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*Image.network(
                      "https://upload.wikimedia.org/wikipedia/tr/d/d3/Sabanc%C4%B1_%C3%9Cniversitesi_logosu.jpg",
                      width: 150,
                    ),*/
                      IconButton(onPressed: () {
                        googleSignUp();
                      },
                        constraints: BoxConstraints(maxHeight: 70),
                        icon: Image.network(
                            "https://ik4.es/wp-content/uploads/2021/08/Como-configurar-Gmail-en-tu-iPhone-o-iPad.jpg"),
                        iconSize: 150,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    else {
      return Feed(analytics: widget.analytics, observer: widget.observer);
    }
  }
}