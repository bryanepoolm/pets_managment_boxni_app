import 'dart:convert';

import 'package:boxni/src/password_screen.dart';
import 'package:boxni/src/recover_passowrd.dart';
import 'package:boxni/src/register_screen.dart';
import 'package:boxni/src/splash_screen.dart';
import 'package:boxni/src/webview_screen.dart';
import 'package:boxni/src/widgets/boton_widget.dart';
import 'package:boxni/src/widgets/campotexto_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'logic/config.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _correoController = TextEditingController();
    final TextEditingController _passworddController = TextEditingController();
    String correo = '', password = '';
    final formkey = new GlobalKey<FormState>();

    Future login() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var body = {'correo': correo, 'password': password};
      var header = {'X-API-KEY': 'petboys'};
      var url = Uri.parse('${Config.base_url}API/Autenticacion');

      var response = await http.post(url, body: body, headers: header);
      var message = jsonDecode(response.body);
      switch (response.statusCode) {
        case 302:
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      WebViewScreen(correo: correo, password: password)));
          break;
        case 200:
          pref.setBool('isLoged', true);
          pref.setString('correo', correo);
          pref.setString('password', password);

          Navigator.push(
              context, MaterialPageRoute(builder: (_) => SplashScreen()));

          break;
        case 401:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message['message'].toString()),
          ));
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message['message'].toString()),
          ));
          print(message);
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 32, right: 32, top: 40),
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/boxni.png',
                    width: 200,
                  ),
                  Text(
                    'Inicia sesión',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CampoTextoWidget(
                    label: 'Correo',
                    controller: _correoController,
                    isPassword: false,
                    tipo: TextInputType.emailAddress,
                    validator: (String val) {
                      if (val == '') {
                        return 'Ingrese su correo';
                      } else {
                        Pattern pattern =
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?)*$";
                        RegExp regex = new RegExp(pattern.toString());
                        if (!regex.hasMatch(val.toString()) || val == null) {
                          return 'Correo invalido';
                        } else {
                          correo = val;
                          return null;
                        }
                      }
                    },
                    onSave: (String correoSave) {
                      correo = correoSave;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CampoTextoWidget(
                    controller: _passworddController,
                    label: 'Contraseña',
                    isPassword: true,
                    tipo: TextInputType.text,
                    validator: (String val) {
                      if (val == '') {
                        return 'Ingrese su contraseña';
                      } else {
                        password = val;
                        return null;
                      }
                    },
                    onSave: (String passwordSaved) {
                      password = passwordSaved;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  BotonWidget(
                    texto: 'Iniciar sesión',
                    onpress: () async {
                      final form = formkey.currentState;
                      if (form!.validate()) {
                        await login();
                      }
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    '¿Has olvidado tu contraseña?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PasswordScreen())),
                    child: Text('Reestablecer contraseña',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text('¿No dispones de una cuenta de Boxni?',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegisterScreen())),
                    child: Text('Registrate aquí',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text('Blazar Networks, S.A. de CV© 2021',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
