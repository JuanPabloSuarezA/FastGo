import 'package:fast_go/src/models/driver.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/driver_provider.dart';
import 'package:fast_go/src/utils/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fast_go/src/utils/snackb.dart' as util;
import 'package:progress_dialog/progress_dialog.dart';

class DriverRegisterController {
  BuildContext context;

  TextEditingController emailController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController confPasswdController = new TextEditingController();
  TextEditingController passwdController = new TextEditingController();
  TextEditingController plateCon1 = new TextEditingController();
  TextEditingController plateCon2 = new TextEditingController();
  TextEditingController plateCon3 = new TextEditingController();
  TextEditingController plateCon4 = new TextEditingController();
  TextEditingController plateCon5 = new TextEditingController();
  TextEditingController plateCon6 = new TextEditingController();

  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  ProgressDialog _progressDialog;

  Future init(BuildContext context) {
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog =
        FGDialog.createProgressDialog(context, "Registrando usuario...");
  }

  void register() async {
    String username = userNameController.text;
    String email = emailController.text.trim();
    String passwd = passwdController.text.trim();
    String confPasswd = confPasswdController.text.trim();

    String plateCode1 = plateCon1.text.trim();
    String plateCode2 = plateCon2.text.trim();
    String plateCode3 = plateCon3.text.trim();
    String plateCode4 = plateCon4.text.trim();
    String plateCode5 = plateCon5.text.trim();
    String plateCode6 = plateCon6.text.trim();

    String plate =
        "$plateCode1$plateCode2$plateCode3 - $plateCode4$plateCode5$plateCode6";

    print("Email: $email");
    print("Password: $passwd");

    if (username.isEmpty ||
        email.isEmpty ||
        passwd.isEmpty ||
        confPasswd.isEmpty) {
      print("Todos los campos son obligatorios");

      util.Snackb.showSnackb(context, "Todos los campos son obligatorios");
      return;
    }

    if (confPasswd != passwd) {
      print("Las contraseñas son diferentes");
      util.Snackb.showSnackb(context, "Las contraseñas son diferentes");
      return;
    }

    if (passwd.length < 6) {
      print("La contraseña debe contener mínimo 6 caracteres");
      util.Snackb.showSnackb(
          context, "La contraseña debe contener mínimo 6 caracteres");
      return;
    }

    _progressDialog.show();

    try {
      bool isRegister = await _authProvider.register(email, passwd);

      if (isRegister) {
        Driver driver = new Driver(
          id: _authProvider.getUser().uid,
          email: _authProvider.getUser().email,
          username: username,
          password: passwd,
          plate: plate,
        );

        await _driverProvider.create(driver);
        _progressDialog.hide();

        Navigator.pushNamedAndRemoveUntil(
            context, "driver/map", (route) => false);
      } else {
        _progressDialog.hide();
        util.Snackb.showSnackb(context, "Fallo al registrarse");
      }
    } catch (error) {
      _progressDialog.hide();
      print("error: $error");
      if (error.toString().compareTo("invalid-email") == 0) {
        util.Snackb.showSnackb(context, "Debes ingresar un Email válido");
      }
    }
  }
}
