import 'package:firebase_auth/firebase_auth.dart';
import 'package:sumate_mobile_app/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _userFromFirebase(User? user) {
    return user ?? null;
  }

  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signupWithMailAndPass(String email, String name, String surname, String username, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      Database(uid: user!.uid).addUser(email, name, surname, username);
      //print(user.uid + " AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      return _userFromFirebase(user);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future loginWithMailAndPass(String mail, String pass) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: mail, password: pass);
      User user = result.user!;
      return _userFromFirebase(user);
    } /*on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found') {
        signupWithMailAndPass(mail, pass);
      }
    }*/ catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}