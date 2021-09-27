import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/utils/ShPref.dart';
import 'package:fast_go/src/utils/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fast_go/src/utils/snackb.dart' as util;

class LoginController {
  BuildContext context;

  TextEditingController emailController = new TextEditingController();

  TextEditingController passwdController = new TextEditingController();

  AuthProvider _authProvider;
  ProgressDialog _progressDialog;

  ShPref _shPref;
  String _kindUser;

  Future init(BuildContext context) async {
    this.context = context;
    _authProvider = new AuthProvider();
    _progressDialog =
        MProgressDialog.createProgressDialog(context, "Iniciando sesión...");
    _shPref = new ShPref();

    _kindUser = await _shPref.read("kindUser");

    print("user: $_kindUser");
  }

  void registerPage() {
    if (_kindUser == "client") {
      Navigator.pushNamed(context, "client/register");
    } else {
      Navigator.pushNamed(context, "driver/register");
    }
  }

  void login() async {
    String email = emailController.text.trim();
    String passwd = passwdController.text.trim();

    print("email: $email");
    print("Password: $passwd");

    _progressDialog.show();

    try {
      bool isLogin = await _authProvider.login(email, passwd);

      _progressDialog.hide();

      if (isLogin) {
        print("Inicio de sesión exitoso");
        util.Snackb.showSnackb(context, "Inicio de sesión exitoso");
      } else {
        print("Fallo al iniciar sesión");
        util.Snackb.showSnackb(context, "Fallo al iniciar sesión");
      }
    } catch (error) {
      _progressDialog.hide();
      print("error: $error");
      if (error.toString().compareTo("wrong-password") == 0) {
        util.Snackb.showSnackb(context, "Contraseña incorrecta");
      } else {
        util.Snackb.showSnackb(context, "Error: $error");
      }
    }
  }
}
