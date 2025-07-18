import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/core/constants.dart';
import 'package:gps_main/features/home/home_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF98B8A6),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF093924), size: 30.0),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'Roboto Slab',
            color: Color(0xFF093924),
            fontSize: 22.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        elevation: 2.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('time', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final desc = data['description'] ?? '';
              final time = data['time'] as Timestamp?;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: NotificationCard(
                  icon: Icons.warning_amber,
                  title: title,
                  subtitle: desc,
                  time: formatTime(time),
                  color: Colors.purple.shade100,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
