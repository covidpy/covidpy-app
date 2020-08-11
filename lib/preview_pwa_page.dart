import 'dart:async';
import 'dart:io';
import 'package:app_covid19_paraguay/providers/pushNotification_provider.dart';
import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:app_covid19_paraguay/util/util.dart';
import 'package:app_covid19_paraguay/widgets/webview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PreviewPwaPage extends StatefulWidget {
  final String titulo;
  final String url;
  final String authToken;
  final NavigationDelegate delegate;
  PreviewPwaPage(
      {Key key, this.titulo, this.url, this.delegate, this.authToken})
      : super(key: key);
  _PreviewPwaPageState createState() => _PreviewPwaPageState();
}

class _PreviewPwaPageState extends State<PreviewPwaPage>
    with WidgetsBindingObserver {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  ProgressDialog pr;

  //PushNotificationProvider push = PushNotificationProvider();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  Location location = new Location();
  PermissionStatus _permissionGranted;
  final _util = new Util();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    /*
    if (_permissionGranted == PermissionStatus.deniedForever ||
        _permissionGranted == PermissionStatus.denied) {
      location.requestPermission().then((permissReq) {
        if (permissReq != PermissionStatus.granted) {
          print("return _permissionGranted $_permissionGranted");
          _showSettings(
              "Para una mejor experiencia de usuario necesitamos que habilites tu ubicación.",
              Icons.check_box,
              Colors.yellow[900]);
          return;
        }
      });
    }
    */
    //push.getToken().then((value) => print(value));

    pushNotificationsStream.asBroadcastStream().listen((onData) {
      print('[DEBUG] there is new data!');
      print(onData);
      this._util.showNotification(onData);
    }, onError: (error) {
      print('[DEBUG] THERE ARE ERRORS HERE');
    });

    // en caso que se acceda desde iOs, inicializa la lib local notifications
    if (Platform.isIOS) {
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('launcher_icon');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);
    }

    pr = new ProgressDialog(context);
    pr.style(message: "Cargando..");
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Covid-19 Paraguay"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      insertLocation();
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _controller.future.then((value) async => value.loadUrl(
            "${Constants.URL_SERVER_WEBVIEW}/datos-basicos?flutter=true&authToken=${widget.authToken}"));
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Color(int.parse("#0a2052".substring(1, 7), radix: 16) +
                      0xFF000000),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Color.fromARGB(40, 0, 0, 0),
                      blurRadius: 15.0,
                      offset: new Offset(0, 10),
                    ),
                  ],
                ),
                child: Container()),
            Expanded(
              child: WebViewGeolocator(
                initialUrl: widget.url,
                gestureNavigationEnabled: true,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                  pr.show();
                },
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (finish) {
                  pr.hide();
                },
                navigationDelegate: widget.delegate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void insertLocation() {
    if (_permissionGranted != PermissionStatus.deniedForever &&
        _permissionGranted != PermissionStatus.denied) {
      _util.procesaUbicacionPaciente('_loadWebView', 'insertLocation',
          isValidTimeLocation: false);
    }
  }
}
