import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/features/auth/login_screen.dart';
import 'package:gps_main/features/auth/welcome_screen.dart';
import 'package:gps_main/features/home/main_screen.dart';
import 'package:gps_main/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
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
      home:WelcomePage(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_mjpeg/flutter_mjpeg.dart';

// void main() => runApp(MaterialApp(home: CameraStream()));

// class CameraStream extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Live Camera")),
//       body: Center(
//         child: Mjpeg(
//           stream: 'http://10.0.21.243:8080/',
//           isLive: true,
//           timeout: Duration(seconds: 30),
//         ),
//       ),
//     );
//   }
// }