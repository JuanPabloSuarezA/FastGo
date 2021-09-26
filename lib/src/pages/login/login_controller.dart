import 'package:flutter/material.dart';

class LoginController {
  BuildContext context;

  TextEditingController emailController = new TextEditingController();

  TextEditingController passwdController = new TextEditingController();

  Future init(BuildContext context) {
    this.context = context;
  }

  void login() {
    String email = emailController.text;
    String passwd = passwdController.text;

    print("email: $email");
    print("Password: $passwd");
  }
}
