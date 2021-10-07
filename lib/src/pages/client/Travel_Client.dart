import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fast_go/src/pages/client/travel_client_controller.dart';
import 'package:fast_go/src/widgets/button_app.dart';

class TravelClient extends StatefulWidget {
  @override
  TravelClientState createState() => TravelClientState();
}

class TravelClientState extends State<TravelClient> {
  TravelClientController _con = new TravelClientController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _con.init(context, refresh);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      print("INICIALIZANDO");

      _con.init(context, refresh);
    });
  }

  Widget nada() {
    return Text("Prueba");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      body: Stack(
        children: [
          Align(
            child: _googleMapsWidget(),
            alignment: Alignment.topCenter,
          ),
          Align(
            child: _cardTravelInfo(),
            alignment: Alignment.bottomCenter,
          ),
          Align(
            child: _buttonBack(),
            alignment: Alignment.topLeft,
          ),
          Align(
            child: _cardKmInfo(_con.km),
            alignment: Alignment.topRight,
          ),
          Align(
            child: _cardMinInfo(_con.min),
            alignment: Alignment.topRight,
          )
        ],
      ),
    );
  }

  Widget _cardTravelInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Desde',
              style: TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              _con.from ?? '',
              style: TextStyle(fontSize: 13),
            ),
            leading: Icon(Icons.location_on),
          ),
          ListTile(
            title: Text(
              'Hasta',
              style: TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              _con.to ?? '',
              style: TextStyle(fontSize: 13),
            ),
            leading: Icon(Icons.my_location),
          ),
          ListTile(
            title: Text(
              'Precio',
              style: TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              '${_con.minTotal?.toStringAsFixed(2) ?? '0.0'}\$ - ${_con.maxTotal?.toStringAsFixed(2) ?? '0.0'}\$',
              style: TextStyle(fontSize: 13),
              maxLines: 1,
            ),
            leading: Icon(Icons.attach_money),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: ButtonApp(
              onPressed: () {},
              text: 'CONFIRMAR',
              textColor: Colors.white,
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  Widget _cardKmInfo(String km) {
    return SafeArea(
        child: Container(
      width: 110,
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.only(right: 10, top: 10),
      decoration: BoxDecoration(
          color: Colors.blue[200],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(
        km ?? '0 Km',
        maxLines: 1,
      ),
    ));
  }

  Widget _cardMinInfo(String min) {
    return SafeArea(
        child: Container(
      width: 110,
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.only(right: 10, top: 35),
      decoration: BoxDecoration(
          color: Colors.cyan[200],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(
        min ?? '0 Min',
        maxLines: 1,
      ),
    ));
  }

  Widget _buttonBack() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(left: 10),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }

  void refresh() {
    setState(() {});
  }
}
