import 'dart:async';
import 'package:app_covid19_paraguay/home_page.dart';
import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:app_covid19_paraguay/providers/auth_provider.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';

class ForgotPwdPage extends StatefulWidget {
  @override
  _ForgotPwdPageState createState() => _ForgotPwdPageState();
}

class _ForgotPwdPageState extends State<ForgotPwdPage>
    with SingleTickerProviderStateMixin {
  final _authProvider = new AuthProvider();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _nroDocCtrl = TextEditingController();
  final _nroTelCtrl = TextEditingController();
  final focus = FocusNode();

  bool _isLoading = false;
  Location location = new Location();
  PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nroDocCtrl.dispose();
    _nroTelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //primary: false,
      appBar: AppBar(
        title: Text('Olvidé mi contraseña'),
        backgroundColor: Color(0xFF0a2052),
      ),
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
              // _header(),
              _content(),
            ],
          ),
        ),
        _footer(),
      ],
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

  Widget _title() {
    return Text("Olvidé mi contraseña",
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
            _inputNroDocumento(),
            SizedBox(height: 20.0),
            _inputTel(),
            SizedBox(height: 20.0),
            _boton(),
            _botonCancelar(),
            SizedBox(height: 10.0),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputNroDocumento() {
    return TextFormField(
      controller: _nroDocCtrl,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (value) =>
          value.isEmpty ? 'El Nro. de documento es requerido' : null,
      onSaved: (value) => _nroDocCtrl.text = value.trim(),
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(focus);
      },
      decoration: InputDecoration(
        icon: Icon(
          Icons.description,
          color: Colors.black54,
          size: 30.0,
        ),
        labelText: 'Nro. de documento',
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.black87),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.0),
        ),
      ),
    );
  }

  Widget _inputTel() {
    return TextFormField(
      controller: _nroTelCtrl,
      focusNode: focus,
      validator: (value) =>
          value.isEmpty ? 'El Nro. de celular es requerido' : null,
      onSaved: (value) => _nroTelCtrl.text = value.trim(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        icon: Icon(
          Icons.phone_android,
          color: Colors.black54,
          size: 30.0,
        ),
        labelText: 'Nro. de Celular',
        labelStyle: TextStyle(color: Colors.black87),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.0),
        ),
        //counterText: "2",
      ),
    );
  }

  Widget _boton() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      color: Colors.red[400],
      child: InkWell(
        onTap: () async {
          if (!_isLoading) {
            _login(context);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(),
              Center(
                child: _isLoading
                    ? SpinKitRing(
                        color: Colors.white,
                        size: 22.0,
                        lineWidth: 2,
                      )
                    : Text(
                        "RECUPERAR CONTRASEÑA",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              /*  _isLoading
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
                    ), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonCancelar() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      // color: Colors.red[400],
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(),
              Center(
                child: Text(
                  "CANCELAR",
                  style: TextStyle(
                      color: Color(0XFF0A2052),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              /*  _isLoading
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
                    ), */
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
    this._authProvider.recoverPassword(context, {
      'nroDocumento': _nroDocCtrl.text,
      'celular': _nroTelCtrl.text
    }).then((response) async {
      if (response != null &&
          response["status"] &&
          response["message"] != null) {
        _showMessage(response["message"], Icons.done, Colors.green);

        Future.delayed(const Duration(milliseconds: 800), () {});
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

  void _showSettings(String mensaje, IconData icono, Color color) {
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
  }

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
