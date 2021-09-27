import 'package:fast_go/src/utils/ShPref.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController {
  BuildContext context;

  ShPref _shPref;

  Future init(BuildContext context) {
    this.context = context;
    this._shPref = new ShPref();
  }

  void loginPage(String user) {
    saveChoiceUser(user);
    Navigator.pushNamed(context, "login");
  }

  void saveChoiceUser(String user) async {
    await _shPref.save("kindUser", user);
  }
}
