import 'dart:async';
import 'package:app_covid19_paraguay/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_covid19_paraguay/login_page.dart';
import 'package:app_covid19_paraguay/models/login_session_model.dart';
import 'package:app_covid19_paraguay/util/util.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.isLoading}) : super(key: key);

  final bool isLoading;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authProvider = new AuthProvider();

  final _util = new Util();

  final String _iconSplash = 'assets/images/icono.png';

  StreamSubscription _sub;

  PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
    
    //print("inicia _deepLinkListener");
    _deepLinkListener();

    // print("inicia splash");
    // _initSplash();

    //print("inicia background geolocation");
    _util.initPlatformState();

    Future.delayed(const Duration(milliseconds: 700), () {
      print("delayed: inicia splash");
      _initSplash(context);
    });

  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _crearBackgroundSplash(),
            ],
          )
        ],
      ),
    );
  }

  void _deepLinkListener() async {
    _sub = getUriLinksStream().listen((Uri uri) async {
      _closeWebView(uri);
    }, onError: (err) {
      print("ERROR");
      print(err);
    });
    Uri initialUri;
    try {
      initialUri = await getInitialUri();
    } on Exception {
      initialUri = null;
    }
    if (initialUri != null) {
      _closeWebView(initialUri);
    }
  }

  void _closeWebView(Uri initialUri) async {
    final isSession = await authProvider.istoken();
    print("path: ${initialUri.path} - $isSession");
    if (initialUri.path == '/logout' && isSession) {
      var session = Provider.of<LoginSessionModel>(context, listen: false);
      session.logout();
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      });
    }
  }

  void _initSplash(BuildContext context) async {
    var session = Provider.of<LoginSessionModel>(context, listen: false);
    String token = await session.token();

    bool isSession = false;
    if (token != null && token != "") {
      isSession = _util.verifyExpToken(token);
    }

    if (isSession) {
      print("Opening webview..");
      _insertLocation();
      _util.openWebView(context, token);

    } else {
      session.logout();
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage())
        );
      });
    }
  }

  Widget _crearBackgroundSplash() {
    var _stack = Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 100, right: 100),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: 1,
            child: widget.isLoading == null || widget.isLoading
                ? Image.asset(_iconSplash)
                : Container(),
          ),
        ),
      ],
    );

    return Expanded(
      flex: 2,
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _stack,
            ]),
      ),
    );
  }

  void _insertLocation() {
    if (_permissionGranted != PermissionStatus.deniedForever &&
        _permissionGranted != PermissionStatus.denied) {
      _util.procesaUbicacionPaciente('_initSplash', 'insertLocation',
          isValidTimeLocation: false);
    }
  }
}
