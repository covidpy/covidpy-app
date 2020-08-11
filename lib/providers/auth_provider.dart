import 'dart:async';
import 'dart:convert';
import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:app_covid19_paraguay/models/datos_ubicacion_model.dart';
import 'package:app_covid19_paraguay/models/login_session_model.dart';
import 'package:app_covid19_paraguay/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class AuthProvider {
  Future<Map<String, dynamic>> authentication(
      BuildContext context, params) async {
    final headers = {'Content-Type': 'application/json'};
    final url = "${Constants.URL_SERVER}/apicovid/rest/covid19/seguridad";

    final response =
        await http.post(url, headers: headers, body: json.encode(params));
    print(response.statusCode);
    print(response.body);
    Map<String, dynamic> result = new Map<String, dynamic>();

    if (response.statusCode == 200) {
      result = json.decode(response.body);
      print(result);

      final storage = new FlutterSecureStorage();
      await storage.write(key: Constants.SESSION_TOKEN, value: result['token']);
      await storage.write(
          key: Constants.SESSION_USUARIO,
          value: json.encode(result['usuario']));

      var loginSession = Provider.of<LoginSessionModel>(context, listen: false);
      loginSession.isLoggedIn = true;
      loginSession.currentUser = UsuarioModel.fromJson(result['usuario']);

      result["status"] = true;
      result["message"] = "OK";
    } else if (response.statusCode == 401) {
      result["status"] = false;
      result["message"] = Constants.ERROR_CREDENCIALES;
    } else {
      result["status"] = false;
      result["message"] = Constants.DEFAULT_ERROR_MSG;
    }

    return result;
  }

  Future<Map<String, dynamic>> recoverPassword(
      BuildContext context, params) async {
    final headers = {'Content-Type': 'application/json'};
    final url =
        "${Constants.URL_SERVER}/apicovid/rest/covid19/seguridad/recuperar-clave";
    final response =
        await http.post(url, headers: headers, body: json.encode(params));
    print(response.body);
    Map<String, dynamic> result = new Map<String, dynamic>();
    if (response.statusCode == 200) {
      // result = json.decode(response.body);
      // print(result); result["status"] = true;
      result["status"] = true;
      result["message"] =
          "Siga las instrucciones del SMS que le hemos enviado para reestableccer su contraseña";
    } else if (response.statusCode == 400) {
      result["status"] = false;
      result["message"] =
          'Nro. de Documento inexistente o Nro. Celular incorrecto';
    } else {
      result["status"] = false;
      result["message"] = Constants.DEFAULT_ERROR_MSG;
    }
    return result;
  }

  Future getDiasCuarentena(BuildContext context, dynamic token) async {
    var auth = await token;
    if (auth != null) {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + auth
      };
      return await http
          .get(
              "${Constants.URL_SERVER}/apicovid/rest/covid19/datos-basicos/dias-cuarentena",
              headers: headers)
          .then((response) {
        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
        return null;
      });
    }
  }

  Future getTokenUnSoloUso(BuildContext context, dynamic token) async {
    var auth = await token;
    if (auth != null) {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + auth
      };
      print(
          "${Constants.URL_SERVER}/apicovid/rest/covid19/seguridad/tokenUnUso");
      return await http
          .post(
              "${Constants.URL_SERVER}/apicovid/rest/covid19/seguridad/tokenUnUso",
              headers: headers)
          .then((response) {
        //print(response.body);
        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
        return null;
      });
    }
  }

  Future istoken() async {
    final storage = new FlutterSecureStorage();
    final token = await storage.read(key: Constants.SESSION_USUARIO);
    return token != null;
  }

  Future<void> insertarUbicacion(String event, String activity,
      bg.Location location, bool isValidTimeLocation) async {
    final storage = new FlutterSecureStorage();
    final usuario = await storage.read(key: Constants.SESSION_USUARIO);
    final token = await storage.read(key: Constants.SESSION_TOKEN);
    final fechaHoraInicio = await storage.read(key: Constants.TIME_LOCATION);

    print("reporta ubicacion");
    UsuarioModel usuarioModel =
        usuario != null ? UsuarioModel.fromJson(json.decode(usuario)) : null;
    if (usuarioModel == null || usuarioModel.id == null) {
      return;
    }

    bool reportaUbicacion = true;
    if (isValidTimeLocation) {
      DateTime _fechaFormat;
      int _tiempoReportePasado = 0;
      int _tiempoReporteUbicacion = 30; // minutes

      if (fechaHoraInicio != null) {
        _fechaFormat = DateTime.parse(fechaHoraInicio);
        _tiempoReportePasado =
            DateTime.now().difference(_fechaFormat).inMinutes;
      }

      if (fechaHoraInicio == null ||
          _tiempoReportePasado > _tiempoReporteUbicacion) {
        // almacena el tiempo de reporte de ubicacion en el storage
        String offset =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
        await storage.write(key: Constants.TIME_LOCATION, value: offset);
      } else {
        reportaUbicacion = false;
      }
    }

    if (reportaUbicacion) {
      DatosUbicacionModel datosUbicacionModel = new DatosUbicacionModel(
          activity: activity,
          event: event,
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
          accuracy: location.coords.accuracy,
          altitude: location.coords.altitude,
          altitudeAccuracy: location.coords.altitudeAccuracy,
          speed: location.coords.speed,
          idUsuario: usuarioModel.id,
          fechaHora: DateTime.now().toIso8601String());

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token
      };
      final url =
          "${Constants.URL_SERVER}/apicovid/rest/covid19/registro-ubicacion/actualizarUbicacionPaciente";
      final response = await http.post(url,
          headers: headers,
          body: datosUbicacionModelToJson(datosUbicacionModel));
      print("reporte ubicacion: ${response.body}");
    } else {
      print("no registra");
    }
  }
}
