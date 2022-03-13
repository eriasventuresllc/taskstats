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

  Future<bool> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      sleep(const Duration(milliseconds: 200));
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }
}
