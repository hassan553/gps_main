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
                  heroTag: 'fab_stream',
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
                      if (mapKey.currentState != null) {
                        print('Calling goToCurrentUserLocation with: $v');
                        mapKey.currentState?.goToCurrentUserLocation(v, data);
                      } else {
                        print('mapKey.currentState is null!');
                      }
                    }
                  },
                  child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                  heroTag: 'fab_camera',
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
                      if (mapKey.currentState != null) {
                        print('Calling goToCurrentUserLocation with: $v');
                        mapKey.currentState?.goToCurrentUserLocation(v, data);
                      } else {
                        print('mapKey.currentState is null!');
                      }
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

class MapSample extends StatefulWidget {
  final Key? key;
  const MapSample({this.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _controller;
  bool _isMapReady = false;
  bool _isLoadingLocation = false;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.895105290714362, 46.34089267395434),
    zoom: 18.4746,
  );

  Marker? _userMarker;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kGooglePlex,
          markers: _userMarker != null ? {_userMarker!} : {},
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            setState(() {
              _isMapReady = true;
            });
          },
        ),
        if (_isLoadingLocation)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        if (!_isMapReady)
          Container(
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  void goToCurrentUserLocation(String result, List<PatienModel?> data) async {
    setState(() {
      _isLoadingLocation = true;
    });

    print('goToCurrentUserLocation started...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      setState(() => _isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      print('Got user position: $latLng');
      if (_controller == null) {
        print('Map controller is null');
        setState(() => _isLoadingLocation = false);
        return;
      }

      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 18.15),
      );

      print('Camera animated to new position');

      setState(() {
        _userMarker = Marker(
          markerId: MarkerId("user"),
          position: latLng,
          infoWindow: InfoWindow(title: 'Tomato'),
          icon: data.first?.markerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            showCustomDialog(context, data);
          },
        );
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Error in goToCurrentUserLocation: $e');
      setState(() => _isLoadingLocation = false);
    }
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
                                    children2: data[index]!.subtitle2.split('\n'),
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
  final List<String> children2;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    required this.children2,
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
              [
                ...children
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
                SizedBox(height: 4),
                ...children2
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
                .toList()
              ],
        ),
      ),
    );
  }
}
