import 'dart:async';
import 'dart:io';
import 'package:app_covid19_paraguay/forgot_pwd_page.dart';
import 'package:app_covid19_paraguay/home_page.dart';
import 'package:app_covid19_paraguay/providers/pushNotification_provider.dart';
import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:app_covid19_paraguay/providers/auth_provider.dart';
import 'package:app_covid19_paraguay/widgets/empty_appbar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_covid19_paraguay/terms_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _authProvider = new AuthProvider();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwrodCtrl = TextEditingController();
  final _focus = FocusNode();
  bool _isLoading = false;
  // Location location = new Location();
  // PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameCtrl?.dispose();
    _passwrodCtrl?.dispose();
    _focus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      primary: false,
      appBar: EmptyAppBar(),
      body: _loginView(context),
    );
  }

  Widget _loginView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _header(),
              _content(),
            ],
          ),
        ),
        _footer(),
      ],
    );
  }

  Widget _title() {
    return Text("Iniciar sesión",
        style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold));
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20.0),
            _inputUsername(),
            SizedBox(height: 20.0),
            _inputPassword(),
            SizedBox(height: 20.0),
            _boton(),
            SizedBox(height: 10.0),
            _terminosCondiciones(),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return SafeArea(
      top: true,
      child: Stack(
        children: <Widget>[
          Container(
            height: 100.0,
            width: double.infinity,
            color: Color(0xFF0a2052),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 35.0,
              ),
              Image.asset(
                'assets/images/gobierno_nacional.png',
                width: 220.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                child: Container(
                  color: Colors.indigo[50],
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Covid-19 Paraguay",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                            color: Colors.indigo[900]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        "Esta es una aplicación del Ministerio de Salud Pública y Bienestar Social para el seguimiento de Casos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              _title(),
              _form(),
              // _bottomBar()
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return new Container(
      height: 65.0,
      color: Color(0xFF0a2052),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/quedate_en_casa.png',
            width: 140.0,
          ),
          SizedBox(
            width: 40.0,
          ),
          Image.asset(
            'assets/images/paraguay_de_la_gente.png',
            width: 140.0,
          ),
        ],
      ),
    );
  }

  Widget _inputUsername() {
    return TextFormField(
      controller: _usernameCtrl,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (value) => value.isEmpty ? 'El usuario es requerido' : null,
      onSaved: (value) => _usernameCtrl.text = value.trim(),
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(_focus);
      },
      decoration: InputDecoration(
        icon: Icon(
          Icons.person,
          color: Colors.black54,
          size: 30.0,
        ),
        hintText: 'Ej. 1234567',
        labelText: 'Cédula (Nro. de documento)',
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.black87),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.0),
        ),
      ),
    );
  }

  Widget _inputPassword() {
    return TextFormField(
      controller: _passwrodCtrl,
      obscureText: true,
      focusNode: _focus,
      validator: (value) => value.isEmpty ? 'La contraseña es requerida' : null,
      onSaved: (value) => _passwrodCtrl.text = value.trim(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        icon: Icon(
          Icons.lock,
          color: Colors.black54,
          size: 30.0,
        ),
        labelText: 'Contraseña',
        hintText: '*********',
        labelStyle: TextStyle(color: Colors.black87),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.0),
        ),
        //counterText: "2",
      ),
    );
  }

  Widget _terminosCondiciones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TermsPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Términos y Condiciones',
                      style: TextStyle(
                          color: Color(0XFF0A2052).withOpacity(0.71),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600),
                    ),
                  )),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ForgotPwdPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                        color: Color(0XFF0A2052).withOpacity(0.71),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _boton() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      color: Colors.red[400],
      child: InkWell(
        onTap: () {
          if (!_isLoading) {
            /* if (_permissionGranted == PermissionStatus.deniedForever ||
                _permissionGranted == PermissionStatus.denied) {
              final PermissionStatus permissionRequestedResult =
                  await location.requestPermission();
              if (permissionRequestedResult != PermissionStatus.granted) {
                print("return _permissionGranted $_permissionGranted");
                _showSettings(
                    "Para una mejor experiencia de usuario necesitamos que habilites tu ubicación.",
                    Icons.check_box,
                    Colors.yellow[900]);
                return;
              }
            }*/
            _login(context);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(),
              Center(
                child: Text(
                  _isLoading ? "Accediendo..." : "INGRESAR",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _isLoading
                  ? Center(
                      child: new SizedBox(
                        width: 25.0,
                        height: 25.0,
                        child: SpinKitRing(
                          color: Colors.white,
                          lineWidth: 3,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    PushNotificationProvider push = PushNotificationProvider();
    String _fcmToken = await push.getToken();

    this._authProvider.authentication(context, {
      'username': _usernameCtrl.text,
      'password': _passwrodCtrl.text,
      'fcmRegistrationToken': _fcmToken,
      'so': Platform.operatingSystem
    }).then((response) async {
      if (response != null && response["status"]) {
        _showMessage("Bienvenido ${response["usuario"]["nombre"]}", Icons.done,
            Colors.green);

        Future.delayed(const Duration(milliseconds: 800), () {
          _usernameCtrl.text = "";
          _passwrodCtrl.text = "";
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        isLoading: false,
                      )));
        });
      } else {
        _showMessage(response["message"], Icons.cancel, Colors.red);
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        _isLoading = false;
      });
      _showMessage(Constants.DEFAULT_ERROR_MSG, Icons.cancel, Colors.red);
      print(err);
    });
  }

  /*void _showSettings(String mensaje, IconData icono, Color color) {
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
          Flexible(child: Text(mensaje)),
        ],
      ),
      action: SnackBarAction(
        label: 'Aceptar',
        textColor: Colors.white,
        onPressed: () {
          AppSettings.openLocationSettings();
        },
      ),
      duration: Duration(seconds: 8),
    ));
  }*/

  void _showMessage(String mensaje, IconData icono, Color color) {
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
          Flexible(child: Text(mensaje)),
        ],
      ),
      duration: Duration(seconds: 5),
    ));
  }
}
