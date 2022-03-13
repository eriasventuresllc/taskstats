import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retro/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  SignIn signIn = SignIn();
  Random random = Random();

  Future<List<String>> getSavedTasks(uid) async {
    try {
      CollectionReference collectionRef = FirebaseFirestore.instance.collection(uid);
      QuerySnapshot collectionSnapshot = await collectionRef.get();
      DocumentSnapshot snapshot = collectionSnapshot.docs[0];
      List<dynamic> wordList = snapshot.get('tasks');
      return List<String>.from(wordList);
    } on RangeError catch (e) {
      return Future.value(['']);
    }
  }

  String formatCurrentDate(now) {
    String date = now.year.toString();
    //now.day.toString();
    if(now.month.toString().length == 1) {
      date += ("0" + now.month.toString());
    } else {
      date += now.month.toString();
    }
    if(now.day.toString().length == 1) {
      date += ("0" + now.day.toString());
    } else {
      date += now.day.toString();
    }
    return date;
  }

  void saveTask(name) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection(uid);
    users.doc('tasks'.toString()).set({'tasks': FieldValue.arrayUnion([name])}, SetOptions(merge: true));
  }

  Future<List<String>> getActivities() async {
    List<String> retval = [];
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection(uid);
    DocumentSnapshot data = await users.doc('tasks').get();
    if(data.exists) {
      var tmp = data.get('tasks');
      retval = List.from(tmp);
    }
    return retval;
  }

  void setSaveTask(String date, String task, int started, int stopped, int duration) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    //String uid = signIn.getCurrentFirebaseUser().uid;
    CollectionReference users = FirebaseFirestore.instance.collection(uid);
    int rand = random.nextInt(999999);
    users.doc(date.toString()).set({rand.toString(): {
      "task": task,
      "started": started,
      "stopped": stopped,
      'duration': duration}}, SetOptions(merge: true));
    // read data
    //DocumentSnapshot data = await users.doc(date.toString()).get();
    //print(data.data());
  }
}