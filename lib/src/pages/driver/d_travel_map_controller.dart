import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_go/src/api/enviroment.dart';
import 'package:fast_go/src/models/client.dart';
import 'package:fast_go/src/models/driver.dart';
import 'package:fast_go/src/models/prices.dart';
import 'package:fast_go/src/models/travel_info.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/client_provider.dart';
import 'package:fast_go/src/providers/geofire_provide.dart';
import 'package:fast_go/src/providers/prices_provider.dart';
import 'package:fast_go/src/providers/push_notifications_provider.dart';
import 'package:fast_go/src/providers/travel_info_provider.dart';
import 'package:fast_go/src/widgets/buttom_sheet_driver_pricetravel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
import 'package:fast_go/src/utils/app_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class DriverTravelMapController {
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
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;
  GeoFireProvider _geoFireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  StreamSubscription<DocumentSnapshot> statusub;
  StreamSubscription<DocumentSnapshot> _driverinfoSub;
  Set<Polyline> polylines = {};
  List<LatLng> points = new List();
  bool isConnect = false;
  ProgressDialog _progressDialog;
  PushNotificationsProvider _pushNotificationsProvider;
  TravelInfoProvider _travelInfoProvider;
  PricesProvider _pricesProvider;
  ClientProvider _clientProvider;

  Driver driver;
  Client _client;
  String _idTravel;
  TravelInfo travelInfo;
  String currentStatus = 'INICIAR VIAJE';
  Color colorStatus = Colors.blueAccent;
  double _distanceBetween;
  Timer _timer;
  int seconds = 0;
  double minutes = 0;
  double mt = 0;
  double km = 0;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _idTravel = ModalRoute.of(context).settings.arguments as String;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    MDriver = await createMarkerImageFromAsset('assets/img/taxi_icon.png');
    _progressDialog = FGDialog.createProgressDialog(context, "Cargando...");
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');
    _pushNotificationsProvider = new PushNotificationsProvider();
    _pricesProvider = new PricesProvider();
    _clientProvider = new ClientProvider();

    checkGPS();
    getdriverInfo();
  }

  void getClientInfo() async {
    _client = await _clientProvider.getClientWithId(_idTravel);
  }

  void getdriverInfo() {
    Stream<DocumentSnapshot> driverStream =
        _driverProvider.getIDStream(_authProvider.getUser().uid);
    _driverinfoSub = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  Future<double> calculatePrice() async {
    Prices prices = await _pricesProvider.getAll();

    if (seconds < 60) seconds = 60;
    if (km == 0) km = 0.1;

    int min = seconds ~/ 60;

    print('=========== MIN TOTALES ==============');
    print(min.toString());

    print('=========== KM TOTALES ==============');
    print(km.toString());

    double priceMin = min * prices.min;
    double priceKm = km * prices.km;

    double total = priceMin + priceKm;

    if (total < prices.minValue) {
      total = prices.minValue;
    }

    print('=========== TOTAL ==============');
    print(total.toString());

    return total;
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

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds = timer.tick;
      minutes = seconds / 60;
      refresh();
    });
  }

  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    statusub?.cancel();
    _driverinfoSub?.cancel();
  }

  void isCloseToPickupPosition(LatLng from, LatLng to) {
    _distanceBetween = Geolocator.distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
    print('------ Distancia: $_distanceBetween--------');
  }

  void updateStatus() {
    if (travelInfo.status == 'accepted') {
      startTravel();
    } else if (travelInfo.status == 'started') {
      finishTravel();
    }
  }

  void startTravel() async {
    if (_distanceBetween <= 1000) {
      Map<String, dynamic> data = {'status': 'started'};
      await _travelInfoProvider.update(data, _idTravel);
      travelInfo.status = 'started';
      currentStatus = 'Finalizar viaje';
      colorStatus = Colors.blueAccent;

      polylines = {};
      points = List();
      //markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      marcador(
          'to', travelInfo.toLat, travelInfo.toLng, 'Destino', '', toMarker);
      LatLng from = new LatLng(_position.latitude, _position.longitude);
      LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLng);
      setPolylines(from, to);
      startTimer();
      refresh();
    } else {
      utils.Snackb.showSnackb(context,
          'Debes estar cerca a la posicion del cliente para iniciar el viaje');
    }

    refresh();
  }

  void openBottomSheet() {
    if (_client == null) return;

    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetDriverInfo(
              imageUrl: '',
              username: _client?.username,
              email: _client?.email,
            ));
  }

  void finishTravel() async {
    _timer.cancel();
    double total = await calculatePrice();
    Map<String, dynamic> data = {'status': 'finished'};
    await _travelInfoProvider.update(data, _idTravel);
    travelInfo.status = 'finished';
    refresh();
  }

  void _getTravelInfo() async {
    travelInfo = await _travelInfoProvider.getById(_idTravel);
    LatLng from = new LatLng(_position.latitude, _position.longitude);
    LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
    marcador('from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker);
    setPolylines(from, to);
    getClientInfo();
  }

  Future<void> setPolylines(LatLng from, LatLng to) async {
    PointLatLng pointFromLatLng = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointToLatLng = PointLatLng(to.latitude, to.longitude);

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Enviroment.API_KEY_MAPS, pointFromLatLng, pointToLatLng);

    for (PointLatLng point in result.points) {
      points.add(LatLng(point.latitude, point.longitude));
    }

    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: Colors.amber,
        points: points,
        width: 6);

    polylines.add(polyline);
    //addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);

    refresh();
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      _getTravelInfo();
      CenterPosition();
      saveLocation();

      marcador('driver', _position.latitude, _position.longitude,
          'tu ubicacion', '', MDriver);
      refresh();

      _positionStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) {
        if (travelInfo?.status == 'started') {
          mt = mt +
              Geolocator.distanceBetween(_position.latitude,
                  _position.longitude, position.latitude, position.longitude);
          km = mt / 1000;
        }
        _position = position;
        marcador('driver', _position.latitude, _position.longitude,
            'tu ubicacion', '', MDriver);

        animateCameraToPosition(_position.latitude, _position.longitude);

        if (travelInfo.fromLat != null && travelInfo.fromLng != null) {
          LatLng from = new LatLng(_position.latitude, _position.longitude);
          LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
          isCloseToPickupPosition(from, to);
        }
        //saveLocation();
        refresh();
        _progressDialog.hide();
      });
    } catch (error) {
      print('Error en la localizacion: $error');
      _progressDialog.hide();
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
    );
    markers[id] = marker;
  }

  void checkGPS() async {
    bool isLocation = await Geolocator.isLocationServiceEnabled();
    if (isLocation) {
      print('GPS activado');
      updateLocation();
    } else {
      print('GPS Desactivado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
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
