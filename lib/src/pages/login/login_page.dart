import 'package:fast_go/src/pages/login/login_controller.dart';
import 'package:fast_go/src/widgets/button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fast_go/src/utils/colors.dart' as util;
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController _loginController = new LoginController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _loginController.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _topDecoration(),
              _labelLogIn(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              _textFieldEmail(),
              _textFieldPasswd(),
              _btnLogIn(
                "Iniciar Sesión",
              ),
              _labelNoRegistration()
            ],
          ),
        ));
  }

  Widget _btnLogIn(String text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: ButtonApp(
        text: text,
        color: util.Colors.fgcolor,
        onPressed: _loginController.login,
      ),
    );
  }

  Widget _labelLogIn() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Text(
        "Inicio de sesión",
        style: TextStyle(
            color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _textFieldEmail() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: TextField(
          controller: _loginController.emailController,
          decoration: InputDecoration(
              hintText: "Correo@upb.edu.co",
              labelText: "Correo electrónico",
              suffixIcon: Icon(
                Icons.email,
                color: util.Colors.fgcolor,
              )),
        ));
  }

  Widget _textFieldPasswd() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: TextField(
          controller: _loginController.passwdController,
          obscureText: true,
          decoration: InputDecoration(
              labelText: "Contraseña",
              suffixIcon: Icon(
                Icons.lock,
                color: util.Colors.fgcolor,
              )),
        ));
  }

  Widget _labelNoRegistration() {
    return Center(
        child: Container(
      child: Text(
        "No te has registrado?",
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    ));
  }

  Widget _topDecoration() {
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        color: util.Colors.fgcolor,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              "assets/img/car.png",
              width: 150,
              height: 100,
            ),
            Text("Fast Go",
                style: GoogleFonts.italianno(
                    textStyle: Theme.of(context).textTheme.headline4,
                    fontSize: 65,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
