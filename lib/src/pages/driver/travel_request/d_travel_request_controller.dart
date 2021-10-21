import 'dart:async';

import 'package:fast_go/src/models/client.dart';
import 'package:fast_go/src/providers/auth_provider.dart';
import 'package:fast_go/src/providers/client_provider.dart';
import 'package:fast_go/src/providers/geofire_provide.dart';
import 'package:fast_go/src/providers/travel_info_provider.dart';
import 'package:fast_go/src/utils/ShPref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DriverTravelRequestController {
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey();
  Function refresh;
  ShPref _shPref;

  String from;
  String to;
  String idClient;
  Client client;

  ClientProvider _clientProvider;
  TravelInfoProvider _travelInfoProvider;
  AuthProvider _authProvider;
  GeoFireProvider _geoFireProvider;

  Timer _timer;
  int segundos = 20;

  Future init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    _shPref = new ShPref();
    _shPref.save('isNotification', 'false');
    _clientProvider = new ClientProvider();
    _travelInfoProvider = new TravelInfoProvider();
    _authProvider = new AuthProvider();
    _geoFireProvider = new GeoFireProvider();

    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print("Arguments: $arguments");
    from = arguments['origin'];
    to = arguments['destination'];
    idClient = arguments['idClient'];

    getClientInfo();
    startTimer();
  }

  void dispose() {
    _timer?.cancel();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      segundos = segundos - 1;
      refresh();
      if (segundos == 0) {
        cancelTravel();
      }
    });
  }

  void acceptTravel() {
    Map<String, dynamic> data = {
      'idDriver': _authProvider.getUser().uid,
      'status': 'accepted'
    };

    _timer?.cancel();

    _travelInfoProvider.update(data, idClient);
    _geoFireProvider.delete(_authProvider.getUser().uid);
    Navigator.pushNamedAndRemoveUntil(
        context, 'driver/travel/map', (route) => false,
        arguments: idClient);
    // Navigator.pushReplacementNamed(context, 'driver/travel/map', arguments: idClient);
  }

  void cancelTravel() {
    Map<String, dynamic> data = {'status': 'no_accepted'};

    _timer?.cancel();

    _travelInfoProvider.update(data, idClient);
    Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
  }

  void getClientInfo() async {
    client = await _clientProvider.getClientWithId(idClient);
    print('Client: ${client.toJson()}');
    refresh();
  }
}
