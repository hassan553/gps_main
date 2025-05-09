import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/core/widgets/app_bars_widget.dart';
import 'package:gps_main/features/home/home_screen.dart';
import 'package:gps_main/features/home/notification_screen.dart';
import 'package:gps_main/features/map/map_screen.dart';
import 'package:gps_main/features/home/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    MappageWidget(),
    const HomeScreen(),
    const ProfileScreen(),
  ];
  List<Widget> appbars(context) => [
    mapAppBar(context),
    homeAppBar(context, displayName),
    profileAppBar(context),
  ];
  getAppBar(index) => appbars(context)[index];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  StreamSubscription<DocumentSnapshot>? _userSubscription;
  String displayName = '';

  @override
  void initState() {
    super.initState();
    _listenToUserName();
  }

  void _listenToUserName() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            setState(() {
              displayName = snapshot.data()?['name'] ?? '';
            });
          }
        });
  }

  @override
  void dispose() {
    _userSubscription
        ?.cancel(); // Important: cancel the stream when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(_selectedIndex),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF557959),
        unselectedItemColor: const Color(0xFF98B8A6),
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
