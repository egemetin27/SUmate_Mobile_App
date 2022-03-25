import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sumate_mobile_app/routes/feed.dart';
import 'package:sumate_mobile_app/routes/welcome.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:sumate_mobile_app/services/database.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sumate_mobile_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({Key, key,  required this.analytics,  required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String mail = "";
  String pass = "";
  late bool isEnteredToApp;
  final _formKey = GlobalKey<FormState>();
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  AuthService auth = AuthService();

  String _message = '';
  int attemptCount = 0;

  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  setEnteredToAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enteredToApp', true);
  }

  loadEnteredToAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnteredToApp = prefs.getBool('enteredToApp')!; }
    );
  }
  /*Future<void> signupUser() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: mail, password: pass);
      print(userCredential.toString());
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      if(e.code == 'email-already-in-use') {
        setmessage('This email is already in use');
      }
      else if(e.code == 'weak-password') {
        setmessage('Weak password, add uppercase, lowercase, digit, special character, emoji, etc.');
      }
    }
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

  Future<void> loginUser() async {
    bool _error = false;
    try {
      UserCredential userCredential = await auth.loginWithMailAndPass(mail, pass);
      print(userCredential.toString());

    } on FirebaseAuthException catch (e) {
      _error = true;
      print(e.toString());
      /*if(e.code == 'user-not-found') {
        auth.signupWithMailAndPass(username, mail, phoneNumber, password);
      }
      else*/ if (e.code == 'wrong-password') {
        setmessage('Please check your password');
      }
    }
    if (!_error) {
      Navigator.pop(context);
      Navigator.pushNamed(context, "/profile");
    }
  }

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'Login', 'LoginState');
    loadEnteredToAppStatus();
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
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          border: Border.all(width: 8, color: AppColors.headingColor),
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
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
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
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null) {
                                return 'E-mail field cannot be empty';
                              } else {
                                String trimmedValue = value.trim();
                                if (trimmedValue.isEmpty) {
                                  return 'E-mail field cannot be empty';
                                }
                                if (!EmailValidator.validate(trimmedValue)) {
                                  return 'Please enter a valid email';
                                }
                              }
                              return null;
                            },
                            onSaved: (value) {
                              if (value != null) {
                                mail = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
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
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null) {
                                return 'Password field cannot be empty';
                              } else {
                                String trimmedValue = value.trim();
                                if (trimmedValue.isEmpty) {
                                  return 'Password field cannot be empty';
                                }
                                if (trimmedValue.length < 8) {
                                  return 'Password must be at least 8 characters long';
                                }
                              }
                              return null;
                            },
                            onSaved: (String? value) {
                              if (value != null) {
                                pass = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            //showAlertDialog("Action", 'Button clicked');

                            auth.loginWithMailAndPass(mail, pass);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Logging in')));
                          }
                        },

                        child: Text(
                          "Login", style: TextStyle(color: AppColors.buttonText),
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
                  SizedBox(
                    height: 15,
                  ),
                  IconButton(onPressed: () {
                    googleSignUp();
                  },
                    constraints: BoxConstraints(maxHeight: 70),
                    icon: Image.network("https://ik4.es/wp-content/uploads/2021/08/Como-configurar-Gmail-en-tu-iPhone-o-iPad.jpg"),
                    iconSize: 150,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "Are you new?",
                          style: DefaultOrange,
                        ),
                      ),
                    ],
                  ),
                  /*Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Sign-Up!",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),*/
                  SizedBox(
                    height: 1,
                  ),
                  /*Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text("Forgot your password?",
                          style: DefaultNiceGray,
                        ),
                      ),
                    ],
                  ),*/

                  SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                            "https://upload.wikimedia.org/wikipedia/tr/d/d3/Sabanc%C4%B1_%C3%9Cniversitesi_logosu.jpg",
                            width: 150,
                      ),
                    ],
                  )
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
