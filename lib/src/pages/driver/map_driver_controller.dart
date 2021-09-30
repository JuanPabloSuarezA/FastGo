import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_go/src/models/driver.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/geofire_provide.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:fast_go/src/utils/snackb.dart' as utils;
import 'package:fast_go/src/utils/app_dialog.dart';
import 'package:fast_go/src/providers/geofire_provide.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/driver_provider.dart';
import 'package:fast_go/src/models/driver.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MapDriverController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
    target: LatLng(7.0760326, -73.0897756),
    zoom: 14.0,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Position _position;
  StreamSubscription<Position> _positionStream;
  BitmapDescriptor MDriver;
  GeoFireProvider _geoFireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  StreamSubscription<DocumentSnapshot> statusub;
  StreamSubscription<DocumentSnapshot> _driverinfoSub;
  bool isConnect = false;
  ProgressDialog _progressDialog;

  Driver driver;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog = ProgressDialog(context);
    MDriver = await CTimg('assets/img/icon_car.png');

    checkGPS();
    getdriverInfo();
  }

  void getdriverInfo() {
    Stream<DocumentSnapshot> driverStream =
        _driverProvider.GetIDStream(_authProvider.getUser().uid);
    _driverinfoSub = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
  }

  void onMapCreaated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"elementType": "geometry","stylers": [{"color": "#242f3e"}]},{"elementType": "labels.text.fill","stylers":[{"color": "#746855"}]},{"elementType": "labels.text.stroke","stylers": [{"color": "#242f3e"}]},{"featureType": "administrative.locality",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "poi",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "poi.park",    "elementType": "geometry",    "stylers": [      {        "color": "#263c3f"      }    ]  },  {    "featureType": "poi.park",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#6b9a76"      }    ]  },  {    "featureType": "road",    "elementType": "geometry",    "stylers": [      {        "color": "#38414e"      }    ]  },  {    "featureType": "road",    "elementType": "geometry.stroke",    "stylers": [      {        "color": "#212a37"      }    ]  },  {    "featureType": "road",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#9ca5b3"      }    ]  },  {    "featureType": "road.highway",    "elementType": "geometry",    "stylers": [      {        "color": "#746855"      }    ]  },  {    "featureType": "road.highway",    "elementType": "geometry.stroke",    "stylers": [      {        "color": "#1f2835"      }    ]  },  {    "featureType": "road.highway",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#f3d19c"      }    ]  },  {    "featureType": "transit",    "elementType": "geometry",    "stylers": [      {        "color": "#2f3948"      }    ]  },  {    "featureType": "transit.station",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "water",    "elementType": "geometry",    "stylers": [      {        "color": "#17263c"      }    ]  },  {    "featureType": "water",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#515c6d"      }    ]  },  {    "featureType": "water",    "elementType": "labels.text.stroke",    "stylers": [      {        "color": "#17263c"      }    ]  }]');
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geoFireProvider.create(
        _authProvider.getUser().uid, _position.latitude, _position.longitude);
    _progressDialog.hide();
  }

  void connect() {
    if (isConnect) {
      //isConnect = false;
      disconnect();
    } else {
      _progressDialog.show();
      //isConnect = true;
      updateLocation();
    }
  }

  void disconnect() {
    _positionStream?.cancel();
    _geoFireProvider.delete(_authProvider.getUser().uid);
  }

  void checkConnect() {
    Stream<DocumentSnapshot> status =
        _geoFireProvider.getlocationID(_authProvider.getUser().uid);

    statusub = status.listen((DocumentSnapshot document) {
      if (document.exists) {
        isConnect = true;
      } else {
        isConnect = false;
      }
      refresh();
    });
  }

  void OpenMenu() {
    key.currentState.openDrawer();
  }

  void dismiss() {
    _positionStream?.cancel();
    statusub?.cancel();
    _driverinfoSub?.cancel();
  }

  void Singout() async {
    await _authProvider.sign();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      CenterPosition();
      saveLocation();

      marcador('driver', _position.latitude, _position.longitude,
          'tu ubicacion', '', MDriver);
      refresh();

      _positionStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) {
        _position = position;
        marcador('driver', _position.latitude, _position.longitude,
            'tu ubicacion', '', MDriver);

        animateCameraToPosition(_position.latitude, _position.longitude);
        saveLocation();
        refresh();
      });
    } catch (error) {
      print('Error en la localizacion: $error');
    }
  }

  void CenterPosition() {
    if (_position != null) {
      animateCameraToPosition(_position.latitude, _position.longitude);
    } else {
      utils.Snackb.showSnackb(
          context, "Activa el gps para obtener tu ubicaciòn");
    }
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 0, target: LatLng(latitude, longitude), zoom: 17)));
    }
  }

  Future<BitmapDescriptor> CTimg(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void marcador(String makerId, double lat, double lng, String title,
      String content, BitmapDescriptor iicon) {
    MarkerId id = MarkerId(makerId);
    Marker marker = Marker(
        markerId: id,
        icon: iicon,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: _position.heading);
    markers[id] = marker;
  }

  void checkGPS() async {
    bool isLocation = await Geolocator.isLocationServiceEnabled();
    if (isLocation) {
      print('GPS activado');
      updateLocation();
      checkConnect();
    } else {
      print('GPS Desactivado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        checkConnect();
        print('GPS activado');
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
