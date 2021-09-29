import 'package:fast_go/src/pages/driver/map_driver_controller.dart';
import 'package:fast_go/src/widgets/button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDriver extends StatefulWidget {
  @override
  _MapDriverState createState() => _MapDriverState();
}

class _MapDriverState extends State<MapDriver> {
  MapDriverController _con = new MapDriverController();

  @override
  void initState() {
    // TODO: implement initState

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [_btnMenu(), _btnPosition()],
                ),
                Expanded(child: Container()),
                _btnConnect()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _btnPosition() {
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        shape: CircleBorder(),
        child: Icon(Icons.location_searching),
      ),
    );
  }

  Widget _btnMenu() {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () {},
        icon: Icon(Icons.menu, color: Colors.white),
      ),
    );
  }

  Widget _btnConnect() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        text: 'Conectarse',
        color: Colors.blueAccent,
        textColor: Colors.white,
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _con.initialPosition,
        onMapCreated: _con.onMapCreaated);
  }
}
