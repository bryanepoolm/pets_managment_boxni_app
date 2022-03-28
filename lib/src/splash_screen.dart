import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/login_screen.dart';
import 'package:boxni/src/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? login = pref.getBool('isLoged');

    if (login == true) {
      bool checkedBiometrics = await localAuth.canCheckBiometrics;

      if (checkedBiometrics) {
        bool autenticated = await localAuth.authenticate(
            localizedReason: 'Autenticacion de seguridad',
            biometricOnly: false);
        print('Autenticacion: $autenticated');
        if (autenticated) {
          String correo = pref.getString('correo').toString();
          String password = pref.getString('password').toString();

          var header = {'X-API-KEY': '${Config.apiKey}'};
          var body = {'correo': correo, 'password': password};
          String route =
              '${Config.base_url}API/Login?email=$correo&key=$password';
          var url = Uri.parse(route);
          var response = await http.post(url, body: body, headers: header);
          print('codigoooo');
          print(response.statusCode);
          if (response.statusCode == 302) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                          correo: correo,
                          password: password,
                        )));
          } else {
            pref.remove('isLoged');
          }
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => LoginScreen()));
        }
      } else {
        //Si no tiene sensor
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
