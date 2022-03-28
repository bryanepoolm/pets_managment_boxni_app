import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebViewScreen extends StatefulWidget {
  final String correo, password;
  WebViewScreen({Key? key, required this.correo, required this.password})
      : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  Future logOutNative() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    flutterWebviewPlugin.dispose();
    pref.remove('isLoged');
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
    print('Init');
    flutterWebviewPlugin.dispose();
    flutterWebviewPlugin.close();
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    flutterWebviewPlugin.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String ruta =
        '${Config.base_url}API/Login?email=${widget.correo}&key=${widget.password}';

    final Set<JavascriptChannel> jsChannels = [
      JavascriptChannel(
          name: 'Mascotas',
          onMessageReceived: (JavascriptMessage message) async {
            //logOutNative();
            SharedPreferences pref = await SharedPreferences.getInstance();
            flutterWebviewPlugin.close();
            pref.remove('isLoged');
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => LoginScreen()));
          }),
    ].toSet();

    final double alto = MediaQuery.of(context).padding.top;
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: EdgeInsets.only(top: alto),
        child: WebviewScaffold(
          url: ruta,
          withJavascript: true,
          withLocalStorage: true,
          javascriptChannels: jsChannels,
          debuggingEnabled: true,
          allowFileURLs: true,
        ),
      ),
    );
    /* return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: alto),
          child: WebView(
            debuggingEnabled: false,
            initialUrl: ruta,
            javascriptChannels: jsChannels,
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: false,
          ),
        ),
      ),
    ); */
  }
}
