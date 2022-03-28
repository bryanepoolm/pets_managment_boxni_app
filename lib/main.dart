import 'package:boxni/src/logic/config.dart';
import 'package:boxni/src/splash_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(Boxni());

// ignore: must_be_immutable
class Boxni extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Config.base_url);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boxni',
      home: SplashScreen(),
    );
  }
}
