import 'dart:async';
import 'dart:convert';
import 'package:fast_go/src/providers/client_provider.dart';
import 'package:fast_go/src/providers/driver_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationsProvider {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  StreamController _streamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get message => _streamController.stream;

  void initPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      Map<String, dynamic> data = message.data;
      print("OnMessage: $data");
      _streamController.sink.add(data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map<String, dynamic> data = message.data;
      print("OnResume: $data");
      _streamController.sink.add(data);
    });
  }

  /* _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print("OnMessage: $message");
      _streamController.sink.add(message);
    }, onLaunch: (Map<String, dynamic> message) {
      print("OnLaunch: $message");
    }, onResume: (Map<String, dynamic> message) {
      print("OnResume: $message");
      _streamController.sink.add(message);
    });
    SI SALE UTILIZAR EL DE ARRIBA :D */

  void saveToken(String idUser, String typeUser) async {
    String token = await _firebaseMessaging.getToken();
    Map<String, dynamic> data = {"token": token};

    if (typeUser == "client") {
      ClientProvider clientProvider = new ClientProvider();
      clientProvider.update(data, idUser);
    } else {
      DriverProvider driverProvider = new DriverProvider();
      driverProvider.update(data, idUser);
    }
  }

  Future<void> sendMessage(String token, Map<String, dynamic> data,
      String title, String body) async {
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA113xcIs:APA91bHagH9RZn3G6EXhjtxfoadO67lSxJ_9A-KWUPDcc5O_KuuPnbnnqMmRk4RuEE_b-KT51wvcT5gA-7j9Zctnxvfpi6Jz-rZa3MxdZMyIGt4qsz0i0g2ZpNZaK_u-UiLhITWWieyY'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Contenido de la aplicación',
            'title': 'FastGO',
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': token
        }));
  }

  void dispose() {
    _streamController?.onCancel;
  }
}
