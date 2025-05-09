import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                child: Container(
                  width: double.infinity,
                  height: 145.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFDFE8E3),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color(0x15000000),
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Color(0xFF557959)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0,
                                  40.0,
                                  7.0,
                                  0.0,
                                ),
                                child: Text(
                                  'Smart Eyes in the Sky,',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    fontFamily: 'Oswald',
                                    color: Color(0xFF557959),
                                    fontSize: 19.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                ),
                                child: Text(
                                  'Solutions at Your Side.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    fontFamily: 'Oswald',
                                    color: Color(0xFF557959),
                                    fontSize: 19.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/image.png',

                          fit: BoxFit.cover,
                          alignment: Alignment(-1.0, 0.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 16.0),
                child: Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontFamily: 'Inter Tight',
                    letterSpacing: 0.0,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
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
                  final displayCount = min(3, notifications.length);

                  return Column(
                    children: List.generate(displayCount, (index) {
                      final data =
                          notifications[index].data() as Map<String, dynamic>;
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
                    }),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(6.0, 8.0, 6.0, 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x15000000),
              offset: Offset(0.0, 2.0),
            ),
          ],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(.5),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xBD0D4311),
                      size: 20.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: 'Inter Tight',
                        letterSpacing: 0.0,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Inter',
                  color: Colors.grey,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
