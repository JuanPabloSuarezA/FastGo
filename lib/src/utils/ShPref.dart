import 'package:shared_preferences/shared_preferences.dart';

import "dart:convert";

class ShPref {
  void save(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return json.decode(preferences.getString(key));
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
