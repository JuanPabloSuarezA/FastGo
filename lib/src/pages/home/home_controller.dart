import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/utils/ShPref.dart';
import 'package:flutter/material.dart';

class HomeController {
  BuildContext context;

  ShPref _shPref;
  AuthProvider _authP;
  String _tUser;

  Future init(BuildContext context) async {
    this.context = context;
    this._shPref = new ShPref();
    _authP = new AuthProvider();
    _tUser = await _shPref.read("kindUser");
    print(_tUser);
    checkLogUser();
  }

  void checkLogUser() {
    print("ejecutando check");
    bool signed = _authP.sign();
    print("ejectando auth sign");

    if (signed) {
      if (_tUser == "client") {
        Navigator.pushNamedAndRemoveUntil(
            context, "client/map", (route) => false);
        print("ejecutando sgine");
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, "driver/map", (route) => false);
        print("ejecutando sgine");
      }
    }
  }

  void loginPage(String user) {
    saveChoiceUser(user);
    Navigator.pushNamed(context, "login");
  }

  void saveChoiceUser(String user) async {
    await _shPref.save("kindUser", user);
  }
}
