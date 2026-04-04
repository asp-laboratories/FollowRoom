import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:followroom_flutter/features/auth/screens/login_screen.dart';
import 'package:followroom_flutter/firebase_options.dart';
import 'package:followroom_flutter/services/session_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SessionData.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FollowRoom',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
