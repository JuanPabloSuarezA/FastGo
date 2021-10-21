import 'package:fast_go/src/pages/driver/d_travel_map_controller.dart';
import 'package:fast_go/src/widgets/button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverTravelMap extends StatefulWidget {
  @override
  _DriverTravelMapState createState() => _DriverTravelMapState();
}

class _DriverTravelMapState extends State<DriverTravelMap> {
  DriverTravelMapController _con = new DriverTravelMapController();

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
      key: _con.key,
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buttonUserInfo(),
                    Column(
                      children: [
                        _cardKmInfo(_con.km?.toStringAsFixed(1)),
                        _cardMinInfo(_con.minutes?.toStringAsFixed(1))
                      ],
                    ),
                    _btnPosition()
                  ],
                ),
                Expanded(child: Container()),
                _btnStatus()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buttonUserInfo() {
    return GestureDetector(
      onTap: _con.openBottomSheet,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
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

  Widget _btnStatus() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed: _con.updateStatus,
        text: _con.currentStatus,
        color: _con.colorStatus,
        textColor: Colors.white,
      ),
    );
  }

  Widget _cardKmInfo(String km) {
    return SafeArea(
        child: Container(
      width: 110,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(
        '${km ?? ''} km',
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    ));
  }

  Widget _cardMinInfo(String min) {
    return SafeArea(
        child: Container(
      width: 110,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(
        '${min ?? ''} seg',
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    ));
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreaated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }

  void refresh() {
    setState(() {});
  }
}
