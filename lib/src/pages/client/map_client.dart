import 'package:fast_go/src/widgets/button_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fast_go/src/pages/client/map_client_controller.dart';

class MapClient extends StatefulWidget {
  @override
  _mapClientState createState() => _mapClientState();
}

class _mapClientState extends State<MapClient> {
  MapClientController _con = new MapClientController();

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
      drawer: _menuBurger(),
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                _btnMenu(),
                _cardGoogle(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_btnHasta(), _btnPosition()],
                ),
                Expanded(child: Container()),
                _btnRequest()
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _iconLocacion(),
          )
        ],
      ),
    );
  }

  Widget _iconLocacion() {
    return Image.asset(
      'assets/img/my_location.png',
      width: 65,
      height: 65,
    );
  }

  Widget _menuBurger() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    _con.client?.username ?? 'Nombre de usuario',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ),
                Container(
                  child: Text(
                    _con.client?.email ?? 'Email',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/img/profile.jpg'),
                  radius: 40,
                )
              ],
            ),
            decoration: BoxDecoration(color: Colors.blueAccent[200]),
          ),
          ListTile(
            title: Text('Editar Perfil'),
            trailing: Icon(Icons.edit),
            // leading: Icon(Icons.cancel),
            onTap: () {},
          ),
          ListTile(
            title: Text('Viajes Realizados'),
            trailing: Icon(Icons.loupe),
            // leading: Icon(Icons.cancel),
            onTap: () {},
          ),
          ListTile(
            title: Text('Cerrar Sesion'),
            trailing: Icon(Icons.power_settings_new),
            // leading: Icon(Icons.cancel),
            onTap: _con.singout,
          ),
        ],
      ),
    );
  }

  Widget _btnHasta() {
    return GestureDetector(
        onTap: _con.centerPosition,
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
                  Icons.refresh_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              )),
        ));
  }

  Widget _btnPosition() {
    return GestureDetector(
        onTap: _con.centerPosition,
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

  Widget _cardGoogle() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _con.from ?? '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Divider(
                  color: Colors.grey,
                  height: 10,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Hasta',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnMenu() {
    return Container(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _con.openMenu,
        icon: Icon(Icons.menu, color: Colors.white),
      ),
    );
  }

  Widget _btnRequest() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed: () {},
        text: 'Solicitar Servicio',
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
      onCameraMove: (position) {
        _con.initialPosition = position;
      },
      onCameraIdle: () async {
        await _con.setlocationInfo();
      },
    );
  }

  void refresh() {
    setState(() {});
  }
}
