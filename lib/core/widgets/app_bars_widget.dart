import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/features/home/home_screen.dart';
import 'package:gps_main/features/home/notification_screen.dart';
import 'package:gps_main/features/map/map_screen.dart';
import 'package:gps_main/features/home/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

homeAppBar(BuildContext context, String displayName) {
  return PreferredSize(
    preferredSize: Size.fromHeight(60.0),
    child: AppBar(
      backgroundColor: Color(0xFF98B8A6),
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 30.0),
              child: Text(
                'Hello, $displayName',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Roboto Slab',
                  color: Color(0xFF093924),
                  fontSize: 24.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 30.0),
            child: Icon(
              Icons.waving_hand_outlined,
              color: Color(0xFF093924),
              size: 23.0,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 30.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
            child: Icon(
              Icons.notifications_sharp,
              color: Color(0xFF093924),
              size: 28.0,
            ),
          ),
        ),
      ],
      centerTitle: true,
      elevation: 2.0,
    ),
  );
}

profileAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Color(0xFF98B8A6),
    automaticallyImplyLeading: false,
    title: Text(
      'My Profile',
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
  );
}

mapAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Color(0xFF98B8A6),
    automaticallyImplyLeading: false,
    title: Text(
      'Map',
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
  );
}
