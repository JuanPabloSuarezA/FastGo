import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_go/src/api/enviroment.dart';
import 'package:fast_go/src/models/driver.dart';
import 'package:fast_go/src/models/travel_info.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/geofire_provide.dart';
import 'package:fast_go/src/providers/push_notifications_provider.dart';
import 'package:fast_go/src/providers/travel_info_provider.dart';
import 'package:fast_go/src/widgets/buttom_sheet_client_pricetravel.dart';
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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fast_go/src/utils/app_dialog.dart';

class ClientTravelMapController {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
    target: LatLng(7.0760326, -73.0897756),
    zoom: 14.0,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
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

  Driver driver;
  LatLng _driverLatLng;
  TravelInfo travelInfo;
  bool isRouteReady = false;
  String currentStatus = '';
  Color colorStatus = Colors.white;
  bool isPickupTravel = false;
  bool isStartTravel = false;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geoFireProvider = new GeoFireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog = FGDialog.createProgressDialog(context, "Cargando...");
    MDriver = await createMarkerImageFromAsset('assets/img/icon_taxi.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');
    _pushNotificationsProvider = new PushNotificationsProvider();

    checkGPS();
  }

  void getDriverLocation(String idDriver) {
    Stream<DocumentSnapshot> stream = _geoFireProvider.getlocationID(idDriver);
    stream.listen((DocumentSnapshot document) {
      GeoPoint geoPoint = document.data()['position']['geopoint'];
      _driverLatLng = new LatLng(geoPoint.latitude, geoPoint.longitude);
      marcador('driver', _driverLatLng.latitude, _driverLatLng.longitude,
          'Tu conductor', '', MDriver);

      refresh();

      if (!isRouteReady) {
        isRouteReady = true;
        checkTravelStatus();
      }
    });
  }

  void pickupTravel() {
    if (!isPickupTravel) {
      isPickupTravel = true;
      LatLng from = new LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
      marcador(
          'from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker);
      setPolylines(from, to);
    }
  }

  void checkTravelStatus() async {
    Stream<DocumentSnapshot> stream =
        _travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
    stream.listen((DocumentSnapshot document) {
      travelInfo = TravelInfo.fromJson(document.data());

      if (travelInfo.status == 'accepted') {
        currentStatus = 'Viaje aceptado';
        colorStatus = Colors.greenAccent;
        pickupTravel();
      } else if (travelInfo.status == 'started') {
        currentStatus = 'Viaje iniciado';
        colorStatus = Colors.blueAccent;
        startTravel();
      } else if (travelInfo.status == 'finished') {
        currentStatus = 'Viaje finalizado';
        colorStatus = Colors.amber;
      }

      refresh();
    });
  }

  void openBottomSheet() {
    if (driver == null) return;

    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetClientInfo(
              imageUrl: '',
              username: driver?.username,
              email: driver?.email,
              plate: driver?.plate,
            ));
  }

  void startTravel() {
    if (!isStartTravel) {
      isStartTravel = true;
      polylines = {};
      points = List();
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      marcador(
          'to', travelInfo.toLat, travelInfo.toLng, 'Destino', '', toMarker);

      LatLng from = new LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLng);

      setPolylines(from, to);
      refresh();
    }
  }

  void _getTravelInfo() async {
    travelInfo = await _travelInfoProvider.getById(_authProvider.getUser().uid);
    animateCameraToPosition(travelInfo.fromLat, travelInfo.fromLng);
    getdriverInfo(travelInfo.idDriver);
    getDriverLocation(travelInfo.idDriver);
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

  void getdriverInfo(String id) async {
    driver = await _driverProvider.getDriverWithId(id);
    refresh();
  }

  void dispose() {
    statusub?.cancel();
    _driverinfoSub?.cancel();
  }

  void onMapCreaated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"elementType": "geometry","stylers": [{"color": "#242f3e"}]},{"elementType": "labels.text.fill","stylers":[{"color": "#746855"}]},{"elementType": "labels.text.stroke","stylers": [{"color": "#242f3e"}]},{"featureType": "administrative.locality",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "poi",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "poi.park",    "elementType": "geometry",    "stylers": [      {        "color": "#263c3f"      }    ]  },  {    "featureType": "poi.park",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#6b9a76"      }    ]  },  {    "featureType": "road",    "elementType": "geometry",    "stylers": [      {        "color": "#38414e"      }    ]  },  {    "featureType": "road",    "elementType": "geometry.stroke",    "stylers": [      {        "color": "#212a37"      }    ]  },  {    "featureType": "road",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#9ca5b3"      }    ]  },  {    "featureType": "road.highway",    "elementType": "geometry",    "stylers": [      {        "color": "#746855"      }    ]  },  {    "featureType": "road.highway",    "elementType": "geometry.stroke",    "stylers": [      {        "color": "#1f2835"      }    ]  },  {    "featureType": "road.highway",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#f3d19c"      }    ]  },  {    "featureType": "transit",    "elementType": "geometry",    "stylers": [      {        "color": "#2f3948"      }    ]  },  {    "featureType": "transit.station",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#d59563"      }    ]  },  {    "featureType": "water",    "elementType": "geometry",    "stylers": [      {        "color": "#17263c"      }    ]  },  {    "featureType": "water",    "elementType": "labels.text.fill",    "stylers": [      {        "color": "#515c6d"      }    ]  },  {    "featureType": "water",    "elementType": "labels.text.stroke",    "stylers": [      {        "color": "#17263c"      }    ]  }]');
    _mapController.complete(controller);

    _getTravelInfo();
  }

  void checkGPS() async {
    bool isLocation = await Geolocator.isLocationServiceEnabled();
    if (isLocation) {
      print('GPS activado');
    } else {
      print('GPS Desactivado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        print('GPS activado');
      }
    }
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 0, target: LatLng(latitude, longitude), zoom: 17)));
    }
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
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
}
