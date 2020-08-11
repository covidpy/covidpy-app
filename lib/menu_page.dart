import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:app_covid19_paraguay/models/login_session_model.dart';
import 'package:app_covid19_paraguay/providers/auth_provider.dart';
import 'package:app_covid19_paraguay/widgets/empty_appbar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final authProvider = new AuthProvider();
  String _diasCuarentena = "01";
  bool _isDias = false;
  Map<String, bool> _isLoading = new Map<String, bool>();

  // Location location = new Location();
  // bool _serviceEnabled = false;
  // String latitud = "";
  // String longitud = "";
  /*void _getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    // location.onLocationChanged.handleError((dynamic err) {
    //   print("error al obtener la ubicacion");
    // }).listen((LocationData currentLocation) {
    //   print("................lcoation...............");
    //   print("${currentLocation.latitude}");
    //   print("${currentLocation.longitude}");
    //   this.latitud = "${currentLocation.latitude}";
    //   this.longitud = "${currentLocation.longitude}";
    //   setState(() {});
    // });
  }*/

  @override
  void initState() {
    super.initState();
    _isLoading["m1"] = false;
    _isLoading["m2"] = false;
    _isLoading["m3"] = false;
    _isLoading["m4"] = false;
    _isLoading["m5"] = false;

    // BackgroundLocation.startLocationService();
    // BackgroundLocation.checkPermissions().then((status) {
    //   print("STATUS PERMISO");
    //   print(status);
    // });
    // BackgroundLocation.getLocationUpdates((location) {
    // setState(() {
    //   contador++;
    //   this.latitude = location.latitude.toString();
    //   this.longitude = location.longitude.toString();
    //   this.accuracy = location.accuracy.toString();
    //   this.altitude = location.altitude.toString();
    //   this.bearing = location.bearing.toString();
    //   this.speed = location.speed.toString();
    // });
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!this._isDias) {
      this._isDias = true;
      this._getDiasCuarentena();
    }

    return Scaffold(
      key: _scaffoldKey,
      primary: false,
      appBar: EmptyAppBar(),
      body: _crearCb(),
    );
  }

  void _getDiasCuarentena() {
    var session = Provider.of<LoginSessionModel>(context, listen: false);
    this.authProvider.getDiasCuarentena(context, session.token()).then((value) {
      if (value != null) {
        String tmpDias = "${value["dias"]}".replaceAll("-", "");
        if (tmpDias.length == 1) {
          tmpDias = "0$tmpDias";
        }
        this._diasCuarentena = tmpDias;
        setState(() {});
      }
    });
  }

  Widget _crearCb() {
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
      child: Stack(
        children: <Widget>[
          ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 110, bottom: 20.0),
            children: <Widget>[
              _crearMenu(),
            ],
          ),
          Stack(
            children: <Widget>[
              _crearContentCb(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _crearContentCb() {
    return Container(
      height: 90.0,
      width: double.infinity,
      color: Colors.indigo[900],
      padding: const EdgeInsets.only(top: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          Image.asset(
            'assets/images/gobierno_nacional.png',
            width: 220.0,
          ),
          // SizedBox(width: 100.0,),
          Padding(
            padding: const EdgeInsets.only(right: 5.0, top: 10.0),
            child: IconButton(
              icon: Icon(
                Icons.add_to_home_screen,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: () async {
                final loginSession =
                    Provider.of<LoginSessionModel>(context, listen: false);
                loginSession.logout();
                Navigator.pushReplacementNamed(context, 'login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearMenu() {
    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Covid-19 Paraguay",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                  color: Colors.indigo[900]),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              "Iniciativa del Gobierno Nacional",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54),
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Image.asset(
                    'assets/images/cuarentena/${this._diasCuarentena}.png')),
            _cardItem(1, Icons.insert_drive_file, "Actualizar estado de salud",
                "ACTUALIZAR_ESTADO_SALUD"),
            _cardItem(2, Icons.location_on, "Actualizar Ubicacion",
                "ACTUALIZAR_UBICACION"),
            _cardItem(3, Icons.person_outline, "Actualizar datos personales",
                "ACTUALIZAR_DATOS"),
            _cardItem(4, Icons.pan_tool, "Notificar contactos",
                "NOTIFICAR_CONTACTOS"),
            _cardItem(5, Icons.notifications, "Mensajes", "MENSAJES"),
            _footerText(),
          ],
        ),
      ),
    );
  }

  Widget _cardItem(int index, IconData icono, String title, String redirect) {
    return Consumer<LoginSessionModel>(builder: (context, usuario, child) {
      return InkWell(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          width: MediaQuery.of(context).size.width,
          height: 80.0,
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.indigo[50])),
            color: Colors.indigo[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _iconoMenuItem(icono),
                SizedBox(
                  width: 10.0,
                ),
                Text("$title",
                    style: TextStyle(color: Colors.black, fontSize: 16.0)),
                SizedBox(
                  width: 10.0,
                ),
                _isLoading != null && _isLoading["m$index"]
                    ? SpinKitCircle(
                        color: Colors.indigo[600],
                        size: 25.0,
                      )
                    : Container(),
              ],
            ),
            onPressed: () async {
              if (_isLoading != null && !_isLoading["m$index"]) {
                String tokenSession = await usuario.token();
                this._menuItemSelected(index, redirect, tokenSession);
              }
            },
          ),
        ),
      );
    });
  }

  Widget _iconoMenuItem(IconData icono) {
    return ClipOval(
      child: Material(
        color: Colors.indigo[500], // button color
        child: InkWell(
          splashColor: Colors.indigo, // inkwell color
          child: SizedBox(
              width: 45.0,
              height: 45.0,
              child: Icon(
                icono,
                color: Colors.white,
                size: 20,
              )),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _footerText() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Text(
          '¿Necesita ayuda para utilizar la App? Llame al (021) 237 44 44 *',
          style: TextStyle(fontSize: 18.0, color: Colors.black54)),
    );
  }

  void _menuItemSelected(int index, String menu, String tokenSession) {
    String redirectView = "";

    setState(() {
      _isLoading["m$index"] = true;
    });

    if (menu == "ACTUALIZAR_ESTADO_SALUD") {
      redirectView = "/reporte-medico";
    }
    if (menu == "ACTUALIZAR_UBICACION") {
      redirectView = "/actualizar-ubicacion";
    }
    if (menu == "ACTUALIZAR_DATOS") {
      redirectView = "/datos-basicos";
    }
    if (menu == "NOTIFICAR_CONTACTOS") {
      redirectView = "/contactos";
    }
    if (menu == "MENSAJES") {
      redirectView = "/notificaciones";
    }

    this.authProvider.getTokenUnSoloUso(context, tokenSession).then((value) {
      setState(() {
        _isLoading["m$index"] = false;
      });
      if (value != null && value != "") {
        String urlView =
            "${Constants.URL_SERVER_WEBVIEW}/login?redirect=$redirectView&token=$value";
        print(urlView);
        //this.openWebView(context, urlView);

      } else {
        _mostrarSnackbar("No se pudo acceder al menú seleccionado.",
            Icons.warning, Colors.yellow[800]);
      }
    });
  }

  void _mostrarSnackbar(String mensaje, IconData icono, Color color) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: color,
      content: Row(
        children: <Widget>[
          Icon(
            icono,
            size: 25.0,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(mensaje),
        ],
      ),
      duration: Duration(seconds: 4),
    ));
  }
}
