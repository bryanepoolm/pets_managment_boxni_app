import 'dart:convert';

import 'package:boxni/src/codeconfirm_screen.dart';
import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/widgets/boton_widget.dart';
import 'package:boxni/src/widgets/campotexto_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordScreen extends StatefulWidget {
  PasswordScreen({Key? key}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool _isExecute = false;
  @override
  Widget build(BuildContext context) {
    final formkey = new GlobalKey<FormState>();
    final TextEditingController _correoController = TextEditingController();
    Future enviarCodigo() async {
      setState(() => _isExecute = true);
      String errorMessage = '';
      String correo = _correoController.text;
      SharedPreferences pref = await SharedPreferences.getInstance();
      String password = pref.getString('password').toString();

      var header = {'X-API-KEY': Config.apiKey};
      var url = Uri.parse('https://boxni.mx/API/SendReset');
      var body = {'correo': correo};
      var response = await http.post(url, body: body, headers: header);
      var message = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CodeConfirmScreen(
                      correo: correo,
                      password: password,
                      isRecoverPassword: true,
                    )));
      } else if (response.statusCode == 400) {
        setState(() => _isExecute = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message['message']),
        ));
      } else {
        setState(() => _isExecute = false);
        errorMessage = message['message'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      }
    }

    return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _isExecute,
          child: Center(
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CampoTextoWidget(
                        controller: _correoController,
                        validator: (String val) {
                          if (val == '') {
                            return 'Ingrese su correo';
                          } else {
                            Pattern pattern =
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                r"{0,253}[a-zA-Z0-9])?)*$";
                            RegExp regex = new RegExp(pattern.toString());
                            if (!regex.hasMatch(val.toString()) ||
                                val == null) {
                              return 'Correo invalido';
                            } else {
                              return null;
                            }
                          }
                        },
                        onSave: (String correoSave) {},
                        label: 'Correo',
                        tipo: TextInputType.emailAddress,
                        isPassword: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: BotonWidget(
              texto: 'Recuperar contraseña',
              onpress: () {
                final form = formkey.currentState;
                if (form!.validate()) {
                  enviarCodigo();
                }
              }),
        ));
  }
}
