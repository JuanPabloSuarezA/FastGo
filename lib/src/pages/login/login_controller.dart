import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class LoginController {
  BuildContext context;

  TextEditingController emailController = new TextEditingController();

  TextEditingController passwdController = new TextEditingController();

  AuthProvider _authProvider;

  Future init(BuildContext context) {
    this.context = context;
    _authProvider = new AuthProvider();
  }

  void login() async {
    String email = emailController.text.trim();
    String passwd = passwdController.text.trim();

    print("email: $email");
    print("Password: $passwd");

    try {
      bool isLogin = await _authProvider.login(email, passwd);

      if (isLogin) {
        print("Inicio de sesión exitoso");
      } else {
        print("Fallo al iniciar sesión");
      }
    } catch (error) {
      print("error: $error");
    }
  }
}
