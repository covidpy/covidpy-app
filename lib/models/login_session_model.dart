import 'dart:convert';

import 'package:app_covid19_paraguay/providers/pushNotification_provider.dart';
import 'package:app_covid19_paraguay/util/constants.dart';
import 'package:app_covid19_paraguay/models/usuario_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginSessionModel extends ChangeNotifier {

  UsuarioModel _currentUser = new UsuarioModel();
  bool _isLoggedIn = false;

  LoginSessionModel() {
    print("_initStorage");
    _initStorage();
  }

  UsuarioModel get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  set currentUser(UsuarioModel usuarioModel) {
    _currentUser = usuarioModel;
    notifyListeners();
  }

  set isLoggedIn(bool loggedIn) {
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  Future _initStorage() async {
    final storage = new FlutterSecureStorage();
    final tokenSession = await storage.read(key: Constants.SESSION_TOKEN);
    final usuario = await storage.read(key: Constants.SESSION_USUARIO);

    this.isLoggedIn = tokenSession != null;
    this.currentUser =
        usuario != null ? UsuarioModel.fromJson(json.decode(usuario)) : null;
  }

  Future<String> token() async {
    try { 
      final storage = new FlutterSecureStorage();
      final tokenSession = await storage.read(key: Constants.SESSION_TOKEN);
      return tokenSession;
    } on Exception catch (_) {
      return null;
    }
  }

  void logout() async {
    try { 
      final storage = new FlutterSecureStorage();
      await storage.delete(key: Constants.SESSION_TOKEN);
      await storage.delete(key: Constants.SESSION_USUARIO);
      await storage.delete(key: Constants.TIME_LOCATION);

      PushNotificationProvider push = PushNotificationProvider();
      await push.logoutFcm();

      this.isLoggedIn = false;
      this.currentUser = null;
    } on Exception catch (_) {
      print("error logout");
      print(_);
    }
  }
  
}
