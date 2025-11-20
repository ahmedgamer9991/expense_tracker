import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/details.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {"/": (context) => Home(), "/details": (context) => Details()},
    );
  }
}
