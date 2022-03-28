import 'package:flutter/material.dart';

class BotonWidget extends StatelessWidget {
  final String texto;
  final VoidCallback onpress;

  const BotonWidget({
    Key? key,
    required this.texto,
    required this.onpress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: this.onpress,
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 42, vertical: 16),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(25)),
      focusColor: Colors.blue,
      hoverColor: Colors.blue,
      highlightColor: Colors.blue,
      color: Colors.white,
      child: Text(
        this.texto,
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }
}
