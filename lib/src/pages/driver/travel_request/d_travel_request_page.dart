import 'package:fast_go/main.dart';
import 'package:fast_go/src/pages/driver/travel_request/d_travel_request_controller.dart';
import 'package:fast_go/src/widgets/button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fast_go/src/utils/colors.dart' as util;

class DriverTravelRequestPage extends StatefulWidget {
  @override
  _DriverTravelRequestPageState createState() =>
      _DriverTravelRequestPageState();
}

class _DriverTravelRequestPageState extends State<DriverTravelRequestPage> {
  DriverTravelRequestController _con = new DriverTravelRequestController();

  @override
  void dispose() {
    super.dispose();
    _con.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _bannerInfoClient(),
          _textFromTo(_con.from ?? "", _con.to ?? ""),
          _textLimite(),
        ],
      ),
      bottomNavigationBar: _buttonsViaje(),
    );
  }

  Widget _bannerInfoClient() {
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        color: util.Colors.fgcolor,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets\img\profile.jpg'),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Text(_con.client?.username ?? '',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _textLimite() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30),
      child: Text(
        _con.segundos.toString(),
        style: TextStyle(fontSize: 50),
      ),
    );
  }

  Widget _buttonsViaje() {
    return Container(
        height: 50,
        width: double.infinity,
        margin: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ButtonApp(
                onPressed: _con.acceptTravel,
                text: "Aceptar",
                color: Colors.green,
                textColor: Colors.white,
                icon: Icons.check_circle,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ButtonApp(
                onPressed: _con.cancelTravel,
                text: "Cancelar",
                color: Colors.red,
                textColor: Colors.white,
                icon: Icons.cancel_outlined,
              ),
            )
          ],
        ));
  }

  Widget _textFromTo(String from, String to) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Recoger en: ", style: TextStyle(fontSize: 22)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            from,
            style: TextStyle(fontSize: 18),
            maxLines: 2,
          ),
        ),
        SizedBox(height: 20),
        Text("Lugar de destino: ", style: TextStyle(fontSize: 22)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            to,
            style: TextStyle(fontSize: 18),
            maxLines: 2,
          ),
        )
      ],
    ));
  }

  void refresh() {
    setState(() {});
  }
}
