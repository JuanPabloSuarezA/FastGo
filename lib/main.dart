import 'package:fast_go/src/pages/client/c_travel_map_page.dart';
import 'package:fast_go/src/pages/client/map_client.dart';
import 'package:fast_go/src/pages/client/request_travel_client.dart';
import 'package:fast_go/src/pages/driver/d_register_page.dart';
import 'package:fast_go/src/pages/driver/d_travel_map_page.dart';
import 'package:fast_go/src/pages/driver/map_driver.dart';
import 'package:fast_go/src/pages/driver/travel_request/d_travel_request_page.dart';
import 'package:fast_go/src/pages/login/login_page.dart';
import 'package:fast_go/src/pages/client/c_register_page.dart';
import 'package:fast_go/src/pages/client/travel_client.dart';
import 'package:fast_go/src/providers/push_notifications_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fast_go/src/pages/home/home_page.dart';
import 'package:fast_go/src/utils/colors.dart' as util;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fast_go/src/pages/client/request_travel_client.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    PushNotificationsProvider pushNotificationsProvider =
        new PushNotificationsProvider();
    pushNotificationsProvider.initPushNotifications();

    pushNotificationsProvider.message.listen((data) {
      print("-----------NOTIFICACIÓN-------------");
      print(data);
      navigatorKey.currentState
          .pushNamed("driver/travel/request", arguments: data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fast Go",
      navigatorKey: navigatorKey,
      initialRoute: "home",
      debugShowCheckedModeBanner: false,
      routes: {
        "home": (context) => HomePage(),
        "login": (context) => LoginPage(),
        "client/register": (context) => ClientRegisterPage(),
        "driver/register": (context) => DriverRegisterPage(),
        "driver/map": (context) => MapDriver(),
        "driver/travel/request": (context) => DriverTravelRequestPage(),
        "driver/travel/map": (context) => DriverTravelMap(),
        "client/map": (context) => MapClient(),
        "client/travel": (context) => TravelClient(),
        "client/request": (context) => RequestTravelClientPage(),
        "client/travel/map": (context) => ClientTravelMap(),
      },
      theme: ThemeData(
          textTheme: GoogleFonts.nobileTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
          ),
          primaryColor: util.Colors.fgcolor),
    );
  }
}
