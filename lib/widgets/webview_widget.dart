import 'dart:async';
import 'dart:convert';
import 'package:app_covid19_paraguay/widgets/positions_options_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'  as geo;
import 'package:location/location.dart';
import 'package:webview_flutter/webview_flutter.dart';
export 'package:webview_flutter/webview_flutter.dart' hide WebView;

class WebViewGeolocator extends StatefulWidget {

  /// If not null invoked once the web view is created.
  final WebViewCreatedCallback onWebViewCreated;

  /// Which gestures should be consumed by the web view.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When this set is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// The initial URL to load.
  final String initialUrl;

  /// Whether Javascript execution is enabled.
  final JavascriptMode javascriptMode;

  /// The set of [JavascriptChannel]s available to JavaScript code running in the web view.
  /// For each [JavascriptChannel] in the set, a channel object is made available for the
  /// JavaScript code in a window property named [JavascriptChannel.name].
  /// The JavaScript code can then call `postMessage` on that object to send a message that will be
  /// passed to [JavascriptChannel.onMessageReceived].
  ///
  /// For example for the following JavascriptChannel:
  ///
  /// ```dart
  /// JavascriptChannel(name: 'Print', onMessageReceived: (JavascriptMessage message) { print(message.message); });
  /// ```
  ///
  /// JavaScript code can call:
  ///
  /// ```javascript
  /// Print.postMessage('Hello');
  /// ```
  ///
  /// To asynchronously invoke the message handler which will print the message to standard output.
  /// Adding a new JavaScript channel only takes affect after the next page is loaded.
  /// Set values must not be null. A [JavascriptChannel.name] cannot be the same for multiple
  /// channels in the list.
  /// A null value is equivalent to an empty set.
  final Set<JavascriptChannel> javascriptChannels;

  /// A delegate function that decides how to handle navigation actions.
  ///
  /// When a navigation is initiated by the WebView (e.g when a user clicks a link)
  /// this delegate is called and has to decide how to proceed with the navigation.
  ///
  /// See [NavigationDecision] for possible decisions the delegate can take.
  ///
  /// When null all navigation actions are allowed.
  ///
  /// Caveats on Android:
  ///
  ///   * Navigation actions targeted to the main frame can be intercepted,
  ///     navigation actions targeted to subframes are allowed regardless of the value
  ///     returned by this delegate.
  ///   * Setting a navigationDelegate makes the WebView treat all navigations as if they were
  ///     triggered by a user gesture, this disables some of Chromium's security mechanisms.
  ///     A navigationDelegate should only be set when loading trusted content.
  ///   * On Android WebView versions earlier than 67(most devices running at least Android L+ should have
  ///     a later version):
  ///     * When a navigationDelegate is set pages with frames are not properly handled by the
  ///       webview, and frames will be opened in the main frame.
  ///     * When a navigationDelegate is set HTTP requests do not include the HTTP referer header.
  final NavigationDelegate navigationDelegate;

  /// Invoked when a page starts loading.
  final PageStartedCallback onPageStarted;

  /// Invoked when a page has finished loading.
  /// This is invoked only for the main frame.
  /// When [onPageFinished] is invoked on Android, the page being rendered may
  /// not be updated yet.
  /// When invoked on iOS or Android, any Javascript code that is embedded
  /// directly in the HTML has been loaded and code injected with
  /// [WebViewController.evaluateJavascript] can assume this.
  final PageFinishedCallback onPageFinished;

  /// Controls whether WebView debugging is enabled.
  /// Setting this to true enables [WebView debugging on Android](https://developers.google.com/web/tools/chrome-devtools/remote-debugging/).
  /// WebView debugging is enabled by default in dev builds on iOS.
  /// To debug WebViews on iOS:
  /// - Enable developer options (Open Safari, go to Preferences -> Advanced and make sure "Show Develop Menu in Menubar" is on.)
  /// - From the Menu-bar (of Safari) select Develop -> iPhone Simulator -> <your webview page>
  /// By default `debuggingEnabled` is false.
  final bool debuggingEnabled;

  /// The value used for the HTTP User-Agent: request header.
  /// A Boolean value indicating whether horizontal swipe gestures will trigger back-forward list navigations.
  /// This only works on iOS.
  /// By default `gestureNavigationEnabled` is false.
  final bool gestureNavigationEnabled;

  /// When null the platform's webview default is used for the User-Agent header.
  /// When the [WebView] is rebuilt with a different `userAgent`, the page reloads and the request uses the new User Agent.
  /// When [WebViewController.goBack] is called after changing `userAgent` the previous `userAgent` value is used until the page is reloaded.
  /// This field is ignored on iOS versions prior to 9 as the platform does not support a custom
  /// user agent.
  /// By default `userAgent` is null.
  final String userAgent;

  /// Which restrictions apply on automatic media playback.
  /// This initial value is applied to the platform's webview upon creation. Any following
  /// changes to this parameter are ignored (as long as the state of the [WebView] is preserved).
  /// The default policy is [AutoMediaPlaybackPolicy.require_user_action_for_all_media_types].
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  WebViewGeolocator({
    Key key,
    this.onWebViewCreated,
    this.initialUrl,
    this.javascriptMode = JavascriptMode.disabled,
    this.javascriptChannels,
    this.navigationDelegate,
    this.gestureRecognizers,
    this.onPageStarted,
    this.onPageFinished,
    this.debuggingEnabled = false,
    this.gestureNavigationEnabled = false,
    this.userAgent,
    this.initialMediaPlaybackPolicy = AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
  })  : assert(javascriptMode != null),
        assert(initialMediaPlaybackPolicy != null);

  @override
  _WebViewGeolocatorState createState() => _WebViewGeolocatorState();
}

class _WebViewGeolocatorState extends State<WebViewGeolocator> {

  WebViewController _webViewGPSController;

  List<StreamSubscription<geo.Position>> webViewGPSPositionStreams = [];

  int parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value) ?? null;
  }

  Future<PositionResponse> getCurrentPosition(PositionOptions positionOptions) async {
    PositionResponse positionResponse = PositionResponse();
    print("[DEBUG]getCurrentPosition.............");
    //int timeout = 55000;
    //if (positionOptions.timeout > 0) timeout = positionOptions.timeout;
    try {
      
      //Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      //GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();
      //  if (geolocationStatus == GeolocationStatus.denied ||
      //     geolocationStatus == GeolocationStatus.granted ||
      //     geolocationStatus == GeolocationStatus.restricted ||
      //     geolocationStatus == GeolocationStatus.unknown) {
      // positionResponse.position = await Future.any([
      //     geolocator.getCurrentPosition(desiredAccuracy: (positionOptions.enableHighAccuracy ? LocationAccuracy.best : LocationAccuracy.medium)),
      //     Future.delayed(Duration(milliseconds: timeout), () {
      //       if (positionOptions.timeout > 0) positionResponse.timedOut = true;
      //       print("[DEBUG] TIMEOUT: ${ positionResponse.timedOut }");
      //       return;
      //     })
      // ]);
      // }

        Location location = new Location();
          PermissionStatus _permissionGranted = await location.hasPermission();
          // if (_permissionGranted == PermissionStatus.denied) {
          //   _permissionGranted = await location.requestPermission();
          // }
          print("[DEBUG] _permissionGranted: $_permissionGranted");
          if (_permissionGranted == PermissionStatus.granted) {
            //print("_permissionGranted $_permissionGranted");
            LocationData data = await location.getLocation();
            //print("latitude ${data.latitude}");
            //print("longitude ${data.longitude}");
            positionResponse.position = geo.Position(
              accuracy: data.accuracy,
              altitude: data.altitude,
              latitude: data.latitude,
              longitude: data.longitude,
              heading: data.heading,
              speed: data.speed,
              speedAccuracy: data.speedAccuracy,
            );
            positionResponse.timedOut = false;

          }  else {
            print("[DEBUG] Add response that GPS is disabled (or not available) on the device.");
          }       
        
    } catch (e) {
       print("[DEBUG] error al obtener la ubicacion.");
       print(e);
    }

    return positionResponse;
  }

  void _geolocationAlertFix() {
    String javascript = '''
      var _flutterGeolocationIndex = 0;
      var _flutterGeolocationSuccess = [];
      var _flutterGeolocationError = [];
      function _flutterGeolocationAlertFix() {
        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}}));
        };
        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
        };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
          return _flutterGeolocationIndex;
        };
        return true;
      };
      setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);
    ''';
    _webViewGPSController.evaluateJavascript(javascript);
  }

  void _geolocationClearWatch(int flutterGeolocationIndex) {
    // Stop gps position stream
    webViewGPSPositionStreams[flutterGeolocationIndex]?.cancel();

    // remove watcher from list
    webViewGPSPositionStreams.remove(flutterGeolocationIndex);

    // Remove functions from array
    String javascript = '''
      function _flutterGeolocationResponse() {
        _flutterGeolocationSuccess[''' +
        flutterGeolocationIndex.toString() +
        '''] = null;
        _flutterGeolocationError[''' +
        flutterGeolocationIndex.toString() +
        '''] = null;
        return true;
      };
      _flutterGeolocationResponse();
    ''';

    _webViewGPSController.evaluateJavascript(javascript);
  }

  void _geolocationGetCurrentPosition(int flutterGeolocationIndex, PositionOptions positionOptions) async {
    print("[DEBUG]_geolocationGetCurrentPosition");
    Future.delayed(const Duration(milliseconds: 500), () {
      getCurrentPosition(positionOptions).then((positionResponse) {
        _geolocationResponse(flutterGeolocationIndex, positionOptions, positionResponse, false);
      });
    });
  }

  void _geolocationResponse(int flutterGeolocationIndex, PositionOptions positionOptions, PositionResponse positionResponse, bool watcher) {
    print("[DEBUG] _geolocationResponse..");
    print(positionResponse.position);
    if (positionResponse.position != null) {
      String javascript = '''
        function _flutterGeolocationResponse() {
          _flutterGeolocationSuccess[''' + flutterGeolocationIndex.toString() + ''']({
            coords: { 
              accuracy: ''' + positionResponse.position.accuracy.toString() + ''', 
              altitude: ''' + positionResponse.position.altitude.toString() + ''', 
              altitudeAccuracy: null, 
              heading: null, 
              latitude: ''' + positionResponse.position.latitude.toString() + ''', 
              longitude: ''' + positionResponse.position.longitude.toString() + ''', 
              speed: ''' + positionResponse.position.speed.toString() + ''' 
            }, 
          });''' +
          (!watcher ? "  _flutterGeolocationSuccess[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          (!watcher ? "  _flutterGeolocationError[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';
      // timestamp: ''' + positionResponse.position.timestamp.millisecondsSinceEpoch.toString() + '''

      _webViewGPSController.evaluateJavascript(javascript);

    } else {
      print("[DEBUG] Return correct error code");
      String javascript = '''
        function _flutterGeolocationResponse() {
          if (_flutterGeolocationError[''' +
          flutterGeolocationIndex.toString() + '''] != null) {''' + (
            positionResponse.timedOut
              ? "_flutterGeolocationError[" + flutterGeolocationIndex.toString() + "]({code: 3, message: 'Request timed out', PERMISSION_DENIED: 1, POSITION_UNAVAILABLE: 2, TIMEOUT: 3}); "
              : "_flutterGeolocationError[" + flutterGeolocationIndex.toString() + "]({code: 1, message: 'User denied Geolocationg', PERMISSION_DENIED: 1, POSITION_UNAVAILABLE: 2, TIMEOUT: 3}); "
          ) +
          "}" +
          (!watcher ? "  _flutterGeolocationSuccess[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          (!watcher ? "  _flutterGeolocationError[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';
      print(javascript);
      _webViewGPSController.evaluateJavascript(javascript);
    }
  }

  void _geolocationWatchPosition(int flutterGeolocationIndex, PositionOptions positionOptions) {
    // init new strem
    var geolocator = geo.Geolocator();
    var locationOptions = geo.LocationOptions(accuracy: (positionOptions.enableHighAccuracy ? geo.LocationAccuracy.best : geo.LocationAccuracy.medium), distanceFilter: 10);
    webViewGPSPositionStreams[flutterGeolocationIndex] = geolocator.getPositionStream(locationOptions).listen((geo.Position position) {
      // Send data to each warcher
      PositionResponse positionResponse = PositionResponse()
        ..position = position;
        print("[DEBUG]_geolocationWatchPosition");
      _geolocationResponse(flutterGeolocationIndex, positionOptions, positionResponse, true);
    });
  }

  JavascriptChannel _flutterJavascriptChannel() {
    print("[DEBUG] CARGA _flutterJavascriptChannel");
    return JavascriptChannel(
        name: '_flutterGeolocation',
        onMessageReceived: (JavascriptMessage message) {
          dynamic geolocationData;
          // try to decode json
          try {
            geolocationData = json.decode(message.message);
          } catch (e) {
            // empty or what ever
            return;
          }
          // Get action from JSON
          final String action = geolocationData['action'] ?? "";
          print("[DEBUG] ACTION: $action");
          switch (action) {
            case "clearWatch":
              _geolocationClearWatch(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0));
              break;
            case "getCurrentPosition":
              _geolocationGetCurrentPosition(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0), PositionOptions().from(geolocationData['option'] ?? null));
              break;
            case "watchPosition":
              _geolocationWatchPosition(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0), PositionOptions().from(geolocationData['option'] ?? null));
              break;
            default:
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    
    Set<JavascriptChannel>   tempJavascriptChannels = <JavascriptChannel>[ _flutterJavascriptChannel(), ].toSet();
    if (widget.javascriptChannels != null) {
      tempJavascriptChannels.addAll(widget.javascriptChannels);
    }

    return WebView(
      key: widget.key,
      onWebViewCreated: (WebViewController controller) {
        //print("[DEBUG]onWebViewCreated");
       // _geolocationAlertFix();
        _webViewGPSController = controller;
        if (widget.onWebViewCreated != null) {
          widget.onWebViewCreated(controller);
        }
      },
      initialUrl: widget.initialUrl,
      javascriptMode: widget.javascriptMode,
      javascriptChannels: tempJavascriptChannels,
      navigationDelegate: (NavigationRequest request) {
        if (widget.navigationDelegate != null) {
          return widget.navigationDelegate(request);
        }
        return NavigationDecision.navigate;
      },
      gestureRecognizers: widget.gestureRecognizers,
      onPageStarted: widget.onPageStarted,
      onPageFinished: (String url) {
        //print("[DEBUG]finish $url");
        Future.delayed(const Duration(milliseconds: 500), () {
          _geolocationAlertFix();
        });
        if (widget.onPageFinished != null) widget.onPageFinished(url);
      },
      debuggingEnabled: widget.debuggingEnabled,
      gestureNavigationEnabled: widget.gestureNavigationEnabled,
      userAgent: widget.userAgent,
      initialMediaPlaybackPolicy: widget.initialMediaPlaybackPolicy,
    );
  }

  @override
  void dispose() {
    print("[DEBUG] DISPOSE");
    webViewGPSPositionStreams.forEach((StreamSubscription<geo.Position> _flutterGeolocationStream) => _flutterGeolocationStream.cancel());
    super.dispose();
  }
}
