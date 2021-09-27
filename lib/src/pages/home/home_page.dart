import 'package:fast_go/src/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fast_go/src/utils/colors.dart' as util;
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final HomeController _homeController = new HomeController();

  @override
  Widget build(BuildContext context) {
    _homeController.init(context);
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue[500]])),
            child: Column(
              children: [
                _topDecoration(context),
                SizedBox(
                  height: 50,
                ),
                _labelQtypeUser("¿Como quieres ingresar?"),
                SizedBox(
                  height: 30,
                ),
                _imageTypeUser("assets/img/clientela.png", context, "client"),
                SizedBox(
                  height: 10,
                ),
                _labelTypeUser("Cliente"),
                SizedBox(
                  height: 30,
                ),
                _imageTypeUser(
                    "assets/img/conductor-de-taxi.png", context, "driver"),
                SizedBox(
                  height: 10,
                ),
                _labelTypeUser("Conductor"),
              ],
            ),
          ),
        ));
  }

  Widget _imageTypeUser(String image, BuildContext context, String user) {
    return GestureDetector(
      onTap: () {
        _homeController.loginPage(user);
      },
      child: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 50,
        backgroundColor: Colors.grey[500],
      ),
    );
  }

  Widget _labelTypeUser(String typeUser) {
    return Text(
      typeUser,
      style: TextStyle(color: Colors.black, fontSize: 16),
    );
  }

  Widget _labelQtypeUser(String text) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _topDecoration(BuildContext context) {
    return ClipPath(
      clipper: WaveClipperOne(),
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
