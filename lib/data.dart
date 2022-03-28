import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:retro/sign_in.dart';
import 'package:retro/task_event.dart';
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

  String formatCurrentDate(DateTime now) {
    String date = now.year.toString();
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

  Future<QuerySnapshot<Object?>> getAnalyticsForRange(DateTime start, DateTime end) async {
    //int startRange = start.toLocal().millisecondsSinceEpoch;
    //int endRange = end.toLocal().millisecondsSinceEpoch + 86400000; // add another day to include the current day
    DateTime endRange = DateTime(end.year, end.month, end.day+1);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> users = FirebaseFirestore.instance.
      collection(uid);
    QuerySnapshot data = await users.where('started', isGreaterThanOrEqualTo:
      start, isLessThanOrEqualTo: endRange).get();
    return data;
  }

  void setSaveTask(String task, DateTime started, int duration) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DateTime end = DateTime.now();
    CollectionReference users = FirebaseFirestore.instance.collection(uid);
    if(duration == 0) {
      duration = (end.millisecondsSinceEpoch - started.millisecondsSinceEpoch)~/1000;
    }
    users.doc().set({
      "task": task,
      "started": started,
      "stopped": end,
      'duration': duration});
  }
}