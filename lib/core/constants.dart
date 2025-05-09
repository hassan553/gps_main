import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Color kPrimaryColor = const Color(0xFF557959);
Color kSecondaryColor = const  Color(0xFF98B8A6);

String formatTime(Timestamp? timestamp) {
  if (timestamp == null) return '';
  final dt = timestamp.toDate();
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

Future<void> storeDataToFirestore({
  required String title,
  required String description,
  required DateTime time,
}) async {
  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'description': description,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'time': Timestamp.fromDate(
        time,
      ), // Converts DateTime to Firestore Timestamp
    });
    print("Data added successfully!");
  } catch (e) {
    print("Error storing data: $e");
  }
}

