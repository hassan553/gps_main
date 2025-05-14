import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/core/constants.dart';
import 'package:gps_main/features/map/camera_screen.dart';
import 'package:http/http.dart' as http;

class CameraStreamScreen extends StatefulWidget {
  const CameraStreamScreen({super.key});

  @override
  State<CameraStreamScreen> createState() => _CameraStreamScreenState();
}

class _CameraStreamScreenState extends State<CameraStreamScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  bool _isStreaming = false;
  Timer? _timer;

  Set<String> resultValues = {};

  Set<String> dateValues = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      await initializeCamera();
    });
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller?.initialize();
    setState(() {});
    startStreaming();
  }

  void startStreaming() {
    _isStreaming = true;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_controller!.value.isInitialized || !_isStreaming) return;

      final image = await _controller?.takePicture();
      setState(() => _loading = true);

      final results = await sendImageAsBase64(File(image!.path));

      setState(() {
        resultValues = results;
        _loading = false;
      });
    });
  }

  Future<Set<String>> sendImageAsBase64(File imageFile) async {
    const apiKey = "Tn5I4QqYn7IBSwoUecyU";
    const modelId = "tomato-leaf-diseases-detect/1";
    final url = Uri.parse(
      "https://serverless.roboflow.com/$modelId?api_key=$apiKey",
    );
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: base64Image,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'];
        final Set<String> results = {};

        if (predictions is List && predictions.isNotEmpty) {
          for (var item in predictions) {
            num confidence = item['confidence'];
           if (confidence > 0.6) {
              results.add(item['class']);
            dateValues.add(item['class']);
            await storeDataToFirestore(
              title: item['class'],
              description: findPatientByKeyword(item['class'])?.subtitle ?? "",
              time: DateTime.now(),
            );
            } else if (confidence > 0.3 && confidence < 0.6) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please enter a clear image',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'This is not a plant',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        setState(() {});

        return results;
      } else {
        print("❌ Error ${response.statusCode}:\n${response.body}");
      }
    } catch (e) {
      print("🔥 Exception: $e");
    }
    return {};
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _isStreaming = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF557959),
        title: const Text("Live Camera Stream"),
      ),
      body:
          _controller == null
              ? SizedBox.shrink()
              : Stack(
                children: [
                  CameraPreview(_controller!),
                  if (_loading)
                    Positioned(
                      top: 100,
                      left: MediaQuery.of(context).size.width / 2 - 20,
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          resultValues
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: Colors.black54,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width / 2 - 70,
                    child:
                        dateValues.isEmpty
                            ? SizedBox.shrink()
                            : ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Color(0xFF557959),
                                ),
                              ),
                              onPressed: () {
                                List<PatienModel?> data = [];
                                for (int i = 0; i < dateValues.length; i++) {
                                  final r = findPatientByKeyword(
                                    dateValues.toList()[i],
                                  );
                                  if (r != null) {
                                    data.add(r);
                                  }
                                }
                                Navigator.pop(context, data);
                              },
                              icon: Icon(Icons.map, color: Colors.white),
                              label: Text(
                                "Show on map",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                  ),
                ],
              ),
    );
  }
}
