import 'package:flutter/material.dart';
import 'package:followroom_flutter/screens/reservacion_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: FollowRoom(),
    );
  }
}
