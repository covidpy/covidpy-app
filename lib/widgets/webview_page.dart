import 'dart:async';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String titulo;
  final String url;
  final NavigationDelegate delegate;
  WebViewPage({Key key, this.titulo, this.url, this.delegate})
      : super(key: key);
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with TickerProviderStateMixin {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  ProgressDialog pr;

  AnimationController controller;
  Animation<double> animation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context);
    pr.style(message: "Cargando..");

    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut);

    controller.repeat();
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _controller.future.then((value) async => value.goBack().then((value) => null)),
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 10),
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
              child: Stack(
                children: <Widget>[
                  WebView(
                    initialUrl: widget.url,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                      // pr.show();
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    onPageStarted: (url) => print(
                        '\n\n\n\n navigates to \n\n\n\n\n\n $url \n\n\n\n\n'),
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (finish) {
                      // pr.hide();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    navigationDelegate: widget.delegate,
                  ),
                  !_isLoading
                      ? Container()
                      : Container(
                          color: Colors.white,
                          child: Center(
                            child: FadeTransition(
                              opacity: animation,
                              child: Image.asset(
                                'assets/images/icono.png',
                                width: MediaQuery.of(context).size.width / 2,
                                height: MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
