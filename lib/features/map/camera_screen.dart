import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_main/core/constants.dart';
import 'package:gps_main/features/map/live_camera_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  @override
  _AiCameraScreenState createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  File? _image;
  List? _predictions;
  bool _loading = false;
  String resultData = '';

  @override
  void initState() {
    super.initState();
    // _loadModel();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _loading = true;
      _image = File(pickedFile.path);
    });

    resultData = await sendImageAsBase64(File(pickedFile.path));
  }

  Set<String> resultValues = {};

  @override
  void dispose() {
    super.dispose();
  }

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
          "Tomato Leaf Diseases  Detection",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: 'Roboto Slab',
            color: Color(0xFF093924),
            fontSize: 16.0,
            letterSpacing: 0.0,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 200),
            const SizedBox(height: 16),
            _loading
                ? CircularProgressIndicator()
                : resultValues.isEmpty
                ? Text("Select an image to predict")
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      resultValues.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(resultValues.toList()[index]),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Color(0xFF557959),
                        ),
                      ),
                      onPressed: () {
                        List<PatienModel?> data = [];
                        for (int i = 0; i < resultValues.length; i++) {
                          final r = findPatientByKeyword(
                            resultValues.toList()[i],
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
                  ],
                ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickImage(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera, color: Colors.white),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xFF557959)),
                  ),

                  label: Text("Camera", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xFF557959)),
                  ),

                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.image, color: Colors.white),
                  label: Text("Gallery", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> sendImageAsBase64(File imageFile) async {
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
        if (predictions is List && predictions.isNotEmpty) {
          for (int i = 0; i < predictions.length; i++) {
            final className = predictions[i]['class'];
            num confidence = predictions[i]['confidence'];
            print('Class: $className');
            if (confidence > 0.6) {
              resultValues.add(className);
              await storeDataToFirestore(
                title: className,
                description: findPatientByKeyword(className)?.subtitle ?? "",
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
        } else {
          print('No predictions found.');
        }
        print("✅ Success:\n${response.body}");
      } else {
        print("❌ Error ${response.statusCode}:\n${response.body}");
      }
      setState(() {
        _loading = false;
      });

      return 'Success';
    } catch (e) {
      print("🔥 Exception: $e");
      setState(() {
        _loading = false;
      });
      return e.toString();
    }
  }
}

class PatienModel {
  String title;
  String subtitle;
  String subtitle2;
  BitmapDescriptor? markerIcon;

  PatienModel({
    required this.subtitle2,
    required this.title,
    required this.subtitle,
    required this.markerIcon,
  });
}

List<PatienModel> patientList = [
  PatienModel(
    title: "Disease : Bacterial Spot",
    subtitle:
        "AI Description : Causes dark, water-soaked spots on leaves and fruits; thrives in humid conditions.",
    subtitle2:
        "AI Solution : Prune and remove affected leaves. Apply copper-based bactericides to control the spread. Avoid overhead watering to reduce humidity around the plant.",
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  ),
  PatienModel(
    title: "Disease : Early_Blight",
    subtitle:
        "AI Description : Fungal disease with dark ringed spots; weakens tomatoes and potatoes.",
    subtitle2:
        "AI Solution : Remove and destroy infected plant parts. Apply fungicides like chlorothalonil or mancozeb to prevent further spread. Crop rotation and selecting resistant varieties help reduce recurrence. ",
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  ),
  PatienModel(
    title: "Healthy",
    subtitle:
        "AI Description : Plant shows no disease; vibrant leaves and strong growth.",
    subtitle2: '',
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    ),
  ),
  PatienModel(
    title: "Disease : Late_blight",
    subtitle:
        "AI Description : Rapidly spreading disease causing dark lesions and crop decay.",
    subtitle2:
        "AI Solution : Remove and dispose of infected plants. Apply fungicides such as copper-based sprays. Ensure proper spacing for air circulation and avoid overhead irrigation to minimize humidity.",
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    ),
  ),
  PatienModel(
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
    title: "Disease : Leaf Mold",
    subtitle:
        "AI Description : Yellow spots and mold on leaves; affects tomatoes in humid areas.",
    subtitle2:
        "AI Solution :  Remove infected leaves and ensure proper spacing between plants for air circulation. Use fungicides like sulfur or copper products, and avoid overhead watering.",
  ),
  PatienModel(
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueViolet,
    ),
    title: "Disease : Target_Spot",
    subtitle:
        "AI Description : Brown, ringed leaf lesions; reduces yield in warm, moist climates.",
    subtitle2:
        "AI Solution : Remove and dispose of infected leaves. Apply fungicides such as tebuconazole or azoxystrobin. Implement good field sanitation and avoid working with wet plants.",
  ),
  PatienModel(
    markerIcon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueMagenta,
    ),
    title: "Disease : Black spot",
    subtitle:
        "AI Description : Black leaf spots with yellowing; common in roses under humidity.",
    subtitle2:
        "AI Solution : Prune and remove infected leaves. Apply fungicides like neem oil or sulfur to control the spread. Ensure good air circulation and water at the base of the plant to prevent fungal spores from splashing onto leaves.",
  ),
];

PatienModel? findPatientByKeyword(String keyword) {
  return patientList.firstWhere(
    (patient) => patient.title.toLowerCase().contains(keyword.toLowerCase()),
  );
}
