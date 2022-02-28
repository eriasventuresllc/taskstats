import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class SignIn {
  late FirebaseAuth fAuth;

  SignIn() {
    fAuth = FirebaseAuth.instance;
  }

  User getCurrentFirebaseUser() {
    return fAuth.currentUser!;
  }

  bool isUserSignedIn() {
    return fAuth.currentUser == null;
  }

  void signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      sleep(const Duration(milliseconds: 200));
    } catch (e) {
      print(e);
    }
  }
}
