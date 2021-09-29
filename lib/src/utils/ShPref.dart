import 'package:shared_preferences/shared_preferences.dart';

import "dart:convert";

class ShPref {
  void save(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    String pref;
    try {
      pref = preferences.getString(key);
      return json.decode(pref);
    } catch (e) {
      return null;
    }
  }

  Future<bool> contains(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(key);
  }

  Future<bool> remove(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }
}
