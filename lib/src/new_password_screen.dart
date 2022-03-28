import 'dart:convert';

import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/splash_screen.dart';
import 'package:boxni/src/webview_screen.dart';
import 'package:boxni/src/widgets/boton_widget.dart';
import 'package:boxni/src/widgets/campotexto_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewPasswordScreen extends StatefulWidget {
  final String correo, codigo;
  NewPasswordScreen({Key? key, required this.correo, required this.codigo})
      : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final formkey = new GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isExecute = false;
  Future setNewPassword() async {
    setState(() => _isExecute = true);

    String errorMessage = '';
    var headers = {'X-API-KEY': Config.apiKey};
    var body = {
      'codigo': widget.codigo,
      'password': _passwordController.text,
      'confirm': _confirmController.text,
      'correo': widget.correo
    };
    var url = Uri.parse('https://boxni.mx/API/setPassword');

    var response = await http.post(url, headers: headers, body: body);
    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool('isLoged', true);
      pref.setString('correo', widget.correo);
      pref.setString('password', _passwordController.text);

      Navigator.push(
          context, MaterialPageRoute(builder: (_) => SplashScreen()));
    } else if (response.statusCode == 400) {
      (data['password'] != '')
          ? errorMessage = errorMessage + data['password'] + "\n"
          : null;
      (data['confirm'] != '')
          ? errorMessage = errorMessage + data['confirm'] + "\n"
          : '';
      (data['correo'] != '')
          ? errorMessage = errorMessage + data['correo'] + "\n"
          : '';
      (data['codigo'] != '')
          ? errorMessage = errorMessage + data['codigo'] + "\n"
          : '';
    } else {
      errorMessage = errorMessage + data;
    }
    setState(() => _isExecute = false);
    if (errorMessage != '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _isExecute,
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CampoTextoWidget(
                    label: 'Nueva contraseña',
                    tipo: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'Ingrese una nueva contraseña';
                      } else if (val.length < 8) {
                        return 'La contraseña debe ser de al menos 8 caracteres';
                      } else {
                        return null;
                      }
                    },
                    onSave: (String correoSave) {}),
                CampoTextoWidget(
                    label: 'Cofnirmar contraseña',
                    tipo: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: _confirmController,
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'Escriba de nuevo su contraseña';
                      } else if (val != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      } else {
                        return null;
                      }
                    },
                    onSave: (String correoSave) {}),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: BotonWidget(
            texto: 'Guardar nueva contraseña',
            onpress: () {
              final form = formkey.currentState;
              if (form!.validate()) {
                setNewPassword();
              }
            }),
      ),
    );
  }
}
