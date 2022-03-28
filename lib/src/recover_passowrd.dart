import 'package:boxni/src/widgets/boton_widget.dart';
import 'package:boxni/src/widgets/campotexto_widget.dart';
import 'package:flutter/material.dart';

class RecoverPasswordSceen extends StatefulWidget {
  const RecoverPasswordSceen({Key? key}) : super(key: key);

  @override
  _RecoverPasswordSceenState createState() => _RecoverPasswordSceenState();
}

class _RecoverPasswordSceenState extends State<RecoverPasswordSceen> {
  @override
  Widget build(BuildContext context) {
    String correo = '';
    final formkey = new GlobalKey<FormState>();
    final TextEditingController _correoController = TextEditingController();

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
        title: Text(
          'Ingrese su correo',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
                    label: 'Correo',
                    tipo: TextInputType.emailAddress,
                    isPassword: false),
              ),
              BotonWidget(
                  texto: 'Recuperar contraseña',
                  onpress: () {
                    final form = formkey.currentState;
                    if (form!.validate()) {
                      print('Done');
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
