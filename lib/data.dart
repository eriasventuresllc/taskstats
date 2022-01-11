import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Data {
  SharedPreferences? _prefs;
  static const DATA_KEY = 'TIME_DATA';

  void setData(Map<String, dynamic> data) async {
    _prefs = await SharedPreferences.getInstance();
    String encodedMap = json.encode(data);
    _prefs!.setString(DATA_KEY, encodedMap);
  }

  Future<Map<String, dynamic>> getData() async {
    _prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(_prefs!.getString(DATA_KEY)!);
    return data;
  }
}