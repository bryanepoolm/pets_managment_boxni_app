import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CampoTextoWidget extends StatelessWidget {
  final Function(String) validator;
  final Function(String) onSave;
  final TextEditingController controller;
  final String label;
  final TextInputType tipo;
  final bool isPassword;
  const CampoTextoWidget({
    Key? key,
    required this.label,
    required this.tipo,
    required this.isPassword,
    required this.controller,
    required this.validator,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 13),
        decoration: InputDecoration(
            fillColor: Colors.white,
            labelText: this.label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        keyboardType: this.tipo,
        obscureText: this.isPassword,
        validator: (val) => validator(val.toString()),
        onSaved: (val) => onSave(val.toString()),
      ),
    );
  }
}
