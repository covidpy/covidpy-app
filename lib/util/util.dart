import 'dart:io';

import 'package:app_covid19_paraguay/preview_pwa_page.dart';
import 'package:flutter/material.dart';
import 'package:app_covid19_paraguay/providers/auth_provider.dart';
import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class Util {
  void openWebView(BuildContext context, String token) {
    //print("${Constants.URL_SERVER_WEBVIEW}?authToken=$token&flutter=true");
    var urlWebView = "${Constants.URL_SERVER_WEBVIEW}?flutter=true&authToken=$token";
    //print("url: $urlWebView");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewPwaPage(
                  titulo: "Covid-19 Paraguay",
                  url:
                      urlWebView,
                  authToken: token,
                  delegate: (NavigationRequest request) {
                    print("uri: ${request.url}");
                    // Acá podríamos controlar que se haga launch de cualquier url que no sea de la PWA
                    if (request.url.startsWith(Constants.DEEP_LINK_SCHEME) ||
                        request.url.startsWith("https://wa.me/")) {
                      _launchURL(request.url);
                      return NavigationDecision.prevent;
                    } else {
                      return NavigationDecision.navigate;
                    }
                  },
                )));
  }

  Future _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'URL no válida $url';
    }
  }

  Future initPlatformState() async {
    
    // Fired whenever a location is recorded
    // bg.BackgroundGeolocation.onLocation(_onLocation);
    
    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    // bg.BackgroundGeolocation.onMotionChange(_onMotionChange);

    // Fired whenever the state of location-services changes.  Always fired at boot
    // bg.BackgroundGeolocation.onProviderChange(_onProviderChange);

    /**
     * Controls the rate (in seconds) the BackgroundGeolocation.onHeartbeat event will fire.
     * On iOS the heartbeat event will fire only when configured with preventSuspend: true.
     * Android minimum interval is 60 seconds. It is impossible to have a heartbeatInterval faster than this on Android.
     */
    print("inicia onHearbeat");
    bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);

    print("inicia onActivityChange");
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);

    // 2.  Configure the plugin
    dynamic configuration; 
    if(Platform.isIOS) {
      configuration = bg.Config(
        reset: true,
        debug: false,
        enableHeadless: true,
        stopOnTerminate: false,
        startOnBoot: true,
        foregroundService: false,
        isMoving: true,
        // Minutes to wait in moving state with no movement before considering the device stationary.
       // Defaults to 5 minutes. When in the moving state, specifies the number of minutes to wait before turning off location-services and transitioning to stationary state after the ActivityRecognition
        stopTimeout: 5,
        useSignificantChangesOnly: false,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
        logLevel: bg.Config.LOG_LEVEL_INFO,
        heartbeatInterval: 60, // On iOS the heartbeat event will fire only when configured with preventSuspend: true.
        preventSuspend: true, // Defaults to false. Set true to prevent iOS from suspending your application after location-services have been switched off while running in the background.
        disableElasticity: true,
        distanceFilter: 100.0,
        //showsBackgroundLocationIndicator: false, // iOS Only: A Boolean indicating whether the status bar changes its appearance when an app uses location services in the background.
        locationAuthorizationAlert: getLocalAuthorizationAlert(),
      );

    } else {
      configuration = bg.Config(
        reset: true,
        debug: false,
        enableHeadless: true,
        stopOnTerminate: false,
        startOnBoot: true,
        foregroundService: false,
        isMoving: true,
       // Minutes to wait in moving state with no movement before considering the device stationary.
       // Defaults to 5 minutes. When in the moving state, specifies the number of minutes to wait before turning off location-services and transitioning to stationary state after the ActivityRecognition
        stopTimeout: 5,
        useSignificantChangesOnly: false,
        //triggerActivities: 'in_vehicle, on_bicycle, on_foot, walking, running', // Android only
        // url: Constants.URL_LOCATION,
        // method: "POST",
        // headers: {"Content-Type":"application/json"},
        // httpTimeout: 60000,
        // locationsOrderDirection: "DESC",
        // locationTemplate:"{fechaHora: <%= timestamp %>,latitude: <%= latitude%>,longitude: <%= longitude%>,accuracy: <%= accuracy%>,altitude: <%= altitude%>,speed: <%= speed%>}",
        // autoSync: true,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
        logLevel: bg.Config.LOG_LEVEL_INFO,
        heartbeatInterval: 60,  // Android minimum interval is 60 seconds. It is impossible to have a heartbeatInterval faster than this on Android.
        // preventSuspend: true, - iOS only
        // scheduleUseAlarmManager: true,
        // schedule: ["1-7 19:10-19:11"],
        disableElasticity: true,
        /**
         *  Android only -  To use locationUpdateInterval you must also configure distanceFilter:0, since distanceFilter overrides locationUpdateInterval
         **/
        distanceFilter: 0,
        locationUpdateInterval: 300000, 
        locationAuthorizationAlert: getLocalAuthorizationAlert(),
      );
    } 

    bg.BackgroundGeolocation.ready(configuration).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });

  }

  getLocalAuthorizationAlert() => {
    "titleWhenNotEnabled": "Tus servicios de ubicación están deshabilitados",
    "titleWhenOff": "Tus servicios de ubicación están deshabilitados",
    "instructions": "Permitir el acceso 'siempre activo' a la ubicación de su dispositivo es esencial para proporcionar notificaciones COVID-19 críticas basadas en la ubicación",
    "cancelButton": "Cancelar",
    "settingsButton": "Configuración",
  };

  void _onHeartbeat(bg.HeartbeatEvent event) async {
    print('[_onHeartbeat] - $event');
    procesaUbicacionPaciente("_onHeartbeat", 'updateLocation');
  }

  // void _onLocation(bg.Location location) async {
  //   print('[_onLocation] - ${location.activity.type}');
  //   procesaUbicacionPaciente("_onLocation", location.activity.type);
  // }

  void _onActivityChange(bg.ActivityChangeEvent event) async {
    print('[_onActivityChange] - ${event.activity}');
    procesaUbicacionPaciente("_onActivityChange", event.activity);
  }
  // void _onProviderChange(bg.ProviderChangeEvent event) async {
  //   print('[_onProviderChange] - ${event.gps.toString()}');
  //   procesaUbicacionPaciente("_onProviderChange", event.gps.toString());
  // }
  // void _onMotionChange(bg.Location location) async {
  //   print('[_onMotionChange] - ${location.activity.type}');
  //   procesaUbicacionPaciente("_onMotionChange", location.activity.type);
  // }

  Map<String, dynamic> getJsonFromJWT(String token) {
    var payload;
    try { 
      payload = Jwt.parseJwt(token);
    } on Exception catch (_) {
      payload = null;
    }
    return payload;
  }

  bool verifyExpToken(String token) { 
    if(token == null || token == "") {
      return false;
    }
    var payload = getJsonFromJWT(token);
    if(payload == null) {
      return false;
    }
    bool isSession = DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
        .isAfter(DateTime.now());
    print(isSession);
    return isSession;
  }

  void procesaUbicacionPaciente(String event, String activity, {bool isValidTimeLocation = true}) {
    final authProvider = new AuthProvider();
    bg.BackgroundGeolocation.getCurrentPosition(
      persist: false, // do not persist this location
      desiredAccuracy: 10, // desire an accuracy of 40 meters or less
      maximumAge: 5000, // Up to 10s old is fine.
      timeout: 10000, // wait 30s before giving up.
      samples: 1, // sample just 1 location
    ).then((bg.Location location) async {
      bool valid = isValidTimeLocation != null && isValidTimeLocation ? true : false;
      await authProvider.insertarUbicacion(event, activity, location, valid);
    }).catchError((error) {
      print("Error while fetching location: $error");
    });
  }

  Future showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('channel id', 'channel name', 'channel description', importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    FlutterLocalNotificationsPlugin notificationsPlugin = new FlutterLocalNotificationsPlugin();
    await notificationsPlugin.show(0,
      message['title'],
      message['body'],
      platformChannelSpecifics,
      payload: message['body'],
    );
  }

}
