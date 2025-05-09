import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/features/map/camera_screen.dart';
import 'package:gps_main/features/map/live_camera_screen.dart';

class MappageWidget extends StatefulWidget {
  const MappageWidget({super.key});

  static String routeName = 'mappage';
  static String routePath = '/mappage';

  @override
  State<MappageWidget> createState() => _MappageWidgetState();
}

class _MappageWidgetState extends State<MappageWidget> {
  final GlobalKey<MapSampleState> mapKey = GlobalKey<MapSampleState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        child: SafeArea(
          top: true,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              MapSample(key: mapKey),
              Positioned(
                bottom: 10,
                left: 10,
                child: FloatingActionButton(
                  backgroundColor: Color(0xFF557959),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AiCameraScreen()),
                    );

                    if (result != null) {
                      final data = result as List<PatienModel?>;
                      String v = '';
                      for (var e in data) {
                        v += '${e?.title ?? ''},';
                      }
                      mapKey.currentState?.goToCurrentUserLocation(
                        data.isEmpty ? '' : v,
                        data,
                      );
                    }
                  },
                  child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                  backgroundColor: Color(0xFF557959),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CameraStreamScreen(),
                      ),
                    );

                    if (result != null) {
                      final data = result as List<PatienModel?>;
                      String v = '';
                      for (var e in data) {
                        v += '${e?.title ?? ''},';
                      }
                      mapKey.currentState?.goToCurrentUserLocation(
                        data.isEmpty ? '' : v,
                        data,
                      );
                    }
                  },
                  child: Icon(Icons.stream, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _controller;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.895105290714362, 46.34089267395434),
    zoom: 18.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(24.895105290714362, 46.34089267395434),
    tilt: 59.440717697143555,
    zoom: 18.151926040649414,
  );
  Marker? _userMarker;

  // @override
  // void didPopNext() {
  //   _goToCurrentUserLocation();
  // }
  //
  // Future<void> _goToCurrentUserLocation() async {
  //   final position = await Geolocator.getCurrentPosition();
  //   final latLng = LatLng(position.latitude, position.longitude);
  //
  //   _controller
  //       ?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 18.151926040649414));
  //
  //   setState(() {
  //     _userMarker = Marker(
  //       markerId: MarkerId("user"),
  //       position: latLng,
  //       infoWindow: InfoWindow(title: "Your Location"),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kGooglePlex,
      markers: _userMarker != null ? {_userMarker!} : {},
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
    );
  }

  void goToCurrentUserLocation(String result, List<PatienModel?> data) async {
    final position = await Geolocator.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 18.15));

    setState(() {
      _userMarker = Marker(
        markerId: MarkerId("user"),
        position: latLng,
        infoWindow: InfoWindow(title: 'Tomato'),
        onTap: () {
          showCustomDialog(context, data);
        },
      );
    });
  }

  void showCustomDialog(BuildContext context, List<PatienModel?> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color(0xFF98B8A6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF557959).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(data.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomExpansionTile(
                                    title: data[index]?.title ?? "",
                                    children: data[index]!.subtitle.split('\n'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final List<String> children;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFDFE8E3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          unselectedWidgetColor: const Color(0xFF557959),
        ),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFF557959),
          iconColor: const Color(0xFF557959),
          textColor: const Color(0xFF557959),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          children:
              children
                  .map(
                    (child) => Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        child,
                        style: const TextStyle(
                          color: Color(0xFF557959),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
