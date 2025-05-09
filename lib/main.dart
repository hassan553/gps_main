import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/features/auth/login_screen.dart';
import 'package:gps_main/features/home/main_screen.dart';
import 'package:gps_main/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Main',
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home:FirebaseAuth.instance.currentUser==null?LoginScreen(): const MainScreen(),
    );
  }
}
