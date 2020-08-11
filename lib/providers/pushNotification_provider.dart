import 'dart:async';
import 'dart:io';
import 'package:app_covid19_paraguay/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// se broadcast: You could use broadcast, which allows to listen stream more than once, but it also prevents from listening past events
final _controller = StreamController<Uri>.broadcast(); 

Stream<Uri> get pushNotificationsStream => _controller.stream;

// Static function to manage notifications when app is closed
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if(message != null) {

    if(message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print('data IS...');
      print(data);
      _controller.sink.add(data.goto);
      print(data.goto);
    }

    if(message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print('notification IS..');
      print(notification);

      if(Platform.isIOS) {
        final util = new Util();
        util.showNotification(notification);
      }
    }

  }
  return Future<void>.value();
}

class PushNotificationProvider {

  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future<String> getToken() async {
    String fcmToken = await _fcm.getToken();
    print("[DEBUG] EL TOKEN FCM ES: $fcmToken");
    return fcmToken;
  }

  logoutFcm() async {
    try { 
      String fcmToken = await _fcm.getToken();
      bool result = await _fcm.deleteInstanceID();
      if(result) {
        fcmToken = await _fcm.getToken();
      }
      print("[DEBUG] EL TOKEN FCM ES: $fcmToken");
    } on Exception catch (_) {
      print("[DEBUG] error logoutFcm");
      print(_);
    }
  }

  Future<void> initialize() async {
    try { 

      if (Platform.isIOS) {
        await _fcm.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
        );
        // _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        //   print("Settings registered:");
        //   print(settings);
        // });
      }

      if (Platform.isAndroid) {
        _fcm.setAutoInitEnabled(true);
      }

      _fcm.configure(
        // App is in foreground
        onMessage: myBackgroundMessageHandler,
        onResume: myBackgroundMessageHandler,
        // App is closed
        onLaunch: myBackgroundMessageHandler,
        // App is in background
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      );
      
    } on Exception catch (_) {
      print("[DEBUG] error initialize");
      print(_);
    }
  }

}
