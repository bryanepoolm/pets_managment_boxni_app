import 'dart:convert';

import 'package:boxni/src/codeconfirm_screen.dart';
import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/widgets/boton_widget.dart';
import 'package:boxni/src/widgets/campotexto_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isExecute = false;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _papController = TextEditingController();
    final TextEditingController _sapController = TextEditingController();
    final TextEditingController _correoController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmController = TextEditingController();

    final formkey = new GlobalKey<FormState>();

    Future registro() async {
      setState(() => _isExecute = true);
      var url = Uri.parse('${Config.base_url}API/Registro');
      var body = {
        'nombre': _nombreController.text,
        'pap': _papController.text,
        'sap': _sapController.text,
        'correo': _correoController.text,
        'password': _passwordController.text,
        'confirm': _confirmController.text
      };
      var header = {'X-API-KEY': '${Config.apiKey}'};

      var response = await http.post(url, headers: header, body: body);
      var message = jsonDecode(response.body);
      String errorMessage = '';
      switch (response.statusCode) {
        case 200:
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CodeConfirmScreen(
                        correo: _correoController.text,
                        password: _passwordController.text,
                        isRecoverPassword: false,
                      )));
          break;
        case 400:
          setState(() => _isExecute = false);
          if (message['message']['nombre'] != '') {
            errorMessage = errorMessage + message["message"]["nombre"] + "\n";
          }
          if (message['message']['pap'] != '') {
            errorMessage = errorMessage + message["message"]["pap"] + "\n";
          }
          if (message['message']['sap'] != '') {
            errorMessage = errorMessage + message["message"]["sap"] + "\n";
          }
          if (message['message']['correo'] != '') {
            errorMessage = errorMessage + message["message"]["correo"] + "\n";
          }
          if (message['message']['password'] != '') {
            errorMessage = errorMessage + message["message"]["password"] + "\n";
          }
          if (message['message']['confirm'] != '') {
            errorMessage = errorMessage + message["message"]["confirm"] + "\n";
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
          ));
          break;
        default:
          setState(() => _isExecute = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message['message'].toString()),
          ));
          print(message);
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: MaterialButton(
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.chevron_left_rounded),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isExecute,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 32, right: 32, top: 20),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registro de nuevo usuario',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 30,
                ),
                CampoTextoWidget(
                    controller: _nombreController,
                    validator: isEmpty,
                    onSave: (String name) {},
                    label: 'Nombre(s)',
                    tipo: TextInputType.text,
                    isPassword: false),
                CampoTextoWidget(
                    controller: _papController,
                    validator: isEmpty,
                    onSave: (String name) {},
                    label: 'Apellido paterno',
                    tipo: TextInputType.text,
                    isPassword: false),
                CampoTextoWidget(
                    controller: _sapController,
                    validator: isEmpty,
                    onSave: (String name) {},
                    label: 'Apellido materno',
                    tipo: TextInputType.text,
                    isPassword: false),
                SizedBox(
                  height: 22,
                ),
                CampoTextoWidget(
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
                        if (!regex.hasMatch(val.toString()) || val == null) {
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
                CampoTextoWidget(
                    controller: _passwordController,
                    validator: isEmpty,
                    onSave: (String name) {},
                    label: 'Contraseña',
                    tipo: TextInputType.text,
                    isPassword: true),
                CampoTextoWidget(
                    controller: _confirmController,
                    validator: (String val) {
                      if (val == _passwordController.text) {
                        return null;
                      } else {
                        return 'Las contraseñas no son iguales';
                      }
                    },
                    onSave: (String name) {},
                    label: 'Confirmar contraseña',
                    tipo: TextInputType.text,
                    isPassword: true),
                BotonWidget(
                    texto: 'Registrar',
                    onpress: () {
                      final form = formkey.currentState;
                      if (form!.validate()) {
                        registro();
                      }
                    }),
                SizedBox(
                  height: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  isEmpty(String val) {
    if (val == '') {
      return 'Complete éste campo';
    } else {
      return null;
    }
  }
}
