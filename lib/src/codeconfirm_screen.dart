import 'dart:convert';

import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/new_password_screen.dart';
import 'package:boxni/src/splash_screen.dart';
import 'package:boxni/src/widgets/boton_widget.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
// ignore: unused_import
import 'package:pinput/pin_put/pin_put_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeConfirmScreen extends StatefulWidget {
  final String correo, password;
  final bool isRecoverPassword;
  const CodeConfirmScreen(
      {Key? key,
      required this.correo,
      required this.password,
      required this.isRecoverPassword})
      : super(key: key);

  @override
  _CodeConfirmScreenState createState() => _CodeConfirmScreenState();
}

class _CodeConfirmScreenState extends State<CodeConfirmScreen> {
  bool _isExecute = false;

  @override
  Widget build(BuildContext context) {
    final _pinPutController = TextEditingController();
    final _pinPutFocusNode = FocusNode();

    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: Color(0xFFF6F5FA),
      borderRadius: BorderRadius.all(
        Radius.circular(22),
      ),
    );

    Future validarCodigo(pin) async {
      setState(() => _isExecute = true);
      var url = Uri.parse('${Config.base_url}API/Codeconfirm');
      var header = {'X-API-KEY': '${Config.apiKey}'};
      var body = {
        'code': pin,
        'correo': widget.correo,
        'isResetPassword': (widget.isRecoverPassword == true) ? 'yes' : 'no'
      };

      var response = await http.post(url, headers: header, body: body);
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => _isExecute = false);

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool('isLoged', true);
        pref.setString('correo', widget.correo);
        pref.setString('password', widget.password);
        if (widget.isRecoverPassword == false) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => SplashScreen()));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      NewPasswordScreen(correo: widget.correo, codigo: pin)));
        }
      } else {
        setState(() => _isExecute = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(json["message"].toString()),
        ));
      }
    }

    Future reenviarCodigo() async {
      setState(() => _isExecute = true);

      var url = Uri.parse('${Config.base_url}API/Reenviar-codigo');
      var header = {'X-API-KEY': '${Config.apiKey}'};
      var body = {'correo': widget.correo};

      var response = await http.post(url, headers: header, body: body);
      var message = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message['message'].toString()),
      ));
      setState(() => _isExecute = false);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: MaterialButton(
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.chevron_left_rounded),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        title: Text(
          'Código de confirmación',
          style: TextStyle(color: Colors.black),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: BotonWidget(
            texto: 'Reenviar código',
            onpress: () {
              reenviarCodigo();
            }),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isExecute,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Codigo enviado a : ${widget.correo}',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 15,
                ),
                PinPut(
                  keyboardType: TextInputType.number,
                  fieldsCount: 4,
                  withCursor: true,
                  textStyle:
                      const TextStyle(fontSize: 25.0, color: Colors.black),
                  eachFieldWidth: 60.0,
                  eachFieldHeight: 55.0,
                  onSubmit: (String pin) => validarCodigo(pin),
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedFieldDecoration: pinPutDecoration,
                  selectedFieldDecoration: pinPutDecoration,
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.fade,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
