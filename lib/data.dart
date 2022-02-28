import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  SharedPreferences? _prefs;
  static const DATA_KEY = 'TIME_DATA';

  void setData(List<dynamic> data) async {
    _prefs = await SharedPreferences.getInstance();
    String encodedMap = json.encode(data);
    _prefs!.setString(DATA_KEY, encodedMap);
  }

  Future<List<String>> getSavedTasks(uid) async {
    try {
      CollectionReference collectionRef = FirebaseFirestore.instance.collection(uid);
      QuerySnapshot collectionSnapshot = await collectionRef.get();
      DocumentSnapshot snapshot = collectionSnapshot.docs[0];
      List<dynamic> wordList = snapshot.get('tasks');
      return new List<String>.from(wordList);
    } on RangeError catch (e) {
      return Future.value(['']);
    }
  }

  void setSaveTask(String date, int started, int stopped, int duration) async {
    //User? firebaseUser = FirebaseAuth.instance.currentUser;
    //String uid = firebaseUser!.uid;
    String uid = '123ABC';
    CollectionReference users = FirebaseFirestore.instance.collection(uid);
    // need to check if it already exists
    users.doc(date.toString()).set({'BD235': {
      "started": started,
      "stopped": stopped,
      'duration': duration}}, SetOptions(merge: true));
    // read data
    DocumentSnapshot data = await users.doc(date.toString()).get();
    print(data.data());
  }

  Future<List<dynamic>> getData() async {
    _prefs = await SharedPreferences.getInstance();
    String? tmp = _prefs!.getString(DATA_KEY);
    List<dynamic> data = [];
    if (tmp != null) {
      data = json.decode(tmp);
    }
    return data;
  }
}