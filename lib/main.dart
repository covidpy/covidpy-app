import 'dart:async';
import 'package:app_covid19_paraguay/providers/pushNotification_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_covid19_paraguay/login_page.dart';
import 'package:app_covid19_paraguay/menu_page.dart';
import 'package:app_covid19_paraguay/models/login_session_model.dart';
import 'package:app_covid19_paraguay/home_page.dart';
import 'package:app_covid19_paraguay/util/util.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

void main() {
  runZoned<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(ChangeNotifierProvider(create: (context) => LoginSessionModel(), child: Covid19PyApp()));
    bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
  });
}

void headlessTask(bg.HeadlessEvent headlessEvent) async {
  String activity = '';
  switch(headlessEvent.name) {
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent response = headlessEvent.event;
      activity = response != null ? response.activity : '_onActivityChange';
    break;
    case bg.Event.TERMINATE:
      bg.Location response = headlessEvent.event;
      activity = response != null ?  response.activity.type : '_onTerminate';
    break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      activity = '$enabled';
    break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent response = headlessEvent.event;
      activity = response != null ? response.toString() : '_onGeofenceChange';
    break;
    // case bg.Event.MOTIONCHANGE: // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    //   bg.ActivityChangeEvent response = headlessEvent.event;
    //   activity = response != null ? response.activity : '_onMotionChange';
    // break;
    case bg.Event.LOCATION:
      bg.Location response = headlessEvent.event;
      activity = response != null ?  response.activity.type : '_onLocation';
    break;
  }
  if(activity != null && activity != '') {
    print('[BackgroundGeolocation] ${headlessEvent.event} - ${headlessEvent.name}');
    final util = new Util();
    util.procesaUbicacionPaciente(headlessEvent.event, activity);
  }
}

class Covid19PyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    PushNotificationProvider push = PushNotificationProvider();
    push.initialize().then((value) => print('initialize firebase'));

    return MaterialApp(
      title: 'Covid-19 Paraguay.',
      debugShowCheckedModeBanner: false,
      initialRoute: "home",
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'menu': (BuildContext context) => MenuPage(),
        'home': (BuildContext context) => HomePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
