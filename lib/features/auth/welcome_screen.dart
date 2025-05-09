import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:gps_main/features/auth/login_screen.dart';
import 'package:gps_main/features/home/main_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _text1Controller;
  late AnimationController _text2Controller;
  late Animation<double> _imageScale;
  late Animation<Offset> _text1Offset;
  late Animation<Offset> _text2Offset;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _text1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _text2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _imageScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );

    _text1Offset = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _text1Controller, curve: Curves.easeInOut),
    );

    _text2Offset = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _text2Controller, curve: Curves.easeInOut),
    );

    // Start animations
    _imageController.forward();
    _text1Controller.forward();
    _text2Controller.forward();

    // Navigate to login page after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  FirebaseAuth.instance.currentUser == null
                      ? LoginScreen()
                      : const MainScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _text1Controller.dispose();
    _text2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF475D4B),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _imageScale,
                child: Image.asset(
                  'assets/icon.png',
                  width: 429.6,
                  height: 221.88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              SlideTransition(
                position: _text1Offset,
                child: Text(
                  "Farmer's",
                  style: const TextStyle(
                    fontFamily: 'Mukta',
                    color: Color(0xFFEAE3D8),
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    height: 0.8,
                  ),
                ),
              ),
              SlideTransition(
                position: _text2Offset,
                child: Padding(
                  padding: const EdgeInsets.only(right: 69.0),
                  child: Text(
                    'Eye',
                    style: const TextStyle(
                      fontFamily: 'Mukta',
                      color: Color(0xFFE8DFD1),
                      fontSize: 20,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
