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
      _con.init(context, refresh);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //print('ejecuntando');
    _con.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      drawer: _MenuBurger(),
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _MenuBurger() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Nombre de usuario',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
              ),
              Container(
                child: Text(
                  'Email',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget _btnPosition() {
    return GestureDetector(
        onTap: _con.CenterPosition,
        child: Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Card(
              shape: CircleBorder(),
              color: Colors.white,
              elevation: 4.0,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.location_searching,
                  color: Colors.grey,
                  size: 20,
                ),
              )),
        ));
  }

  Widget _btnMenu() {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.OpenMenu,
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
        onPressed: _con.connect,
        text: _con.isConnect ? 'Desconectarse' : 'Conectarse',
        color: _con.isConnect ? Colors.red : Colors.blueAccent,
        textColor: Colors.white,
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreaated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
    );
  }

  void refresh() {
    setState(() {});
  }
}
