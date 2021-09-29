import 'package:fast_go/src/models/client.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/client_provider.dart';
import 'package:fast_go/src/utils/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fast_go/src/utils/snackb.dart' as util;
import 'package:progress_dialog/progress_dialog.dart';

class ClientRegisterController {
  BuildContext context;

  TextEditingController emailController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController confPasswdController = new TextEditingController();
  TextEditingController passwdController = new TextEditingController();

  AuthProvider _authProvider;
  ClientProvider _clientProvider;
  ProgressDialog _progressDialog;

  Future init(BuildContext context) {
    this.context = context;
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();
    _progressDialog =
        FGDialog.createProgressDialog(context, "Registrando usuario...");
  }

  void register() async {
    String username = userNameController.text;
    String email = emailController.text.trim();
    String passwd = passwdController.text.trim();
    String confPasswd = confPasswdController.text.trim();

    print("email: $email");
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
        Client client = new Client(
          id: _authProvider.getUser().uid,
          email: _authProvider.getUser().email,
          username: username,
          password: passwd,
        );

        await _clientProvider.create(client);
        _progressDialog.hide();

        Navigator.pushNamedAndRemoveUntil(
            context, "client/map", (route) => false);
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
