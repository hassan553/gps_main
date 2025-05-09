import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_main/core/constants.dart';
import 'package:gps_main/features/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (doc.exists) {
        setState(() {
          nameController.text = doc.data()?['name'] ?? '';
          emailController.text = user.email ?? '';
          imageUrl = doc.data()?['imageUrl'];
          passwordController.text = doc.data()?['password'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Reauthenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      String? uploadedImageUrl;

      // Upload image if changed
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref(
          'profile_images/${user.uid}.jpg',
        );
        await ref.putFile(_imageFile!);
        uploadedImageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection("users").doc(user.uid).set({
        'name': nameController.text.trim(),
        'imageUrl': uploadedImageUrl ?? imageUrl,
        // 'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }, SetOptions(merge: true));

      setState(() {
        imageUrl = uploadedImageUrl ?? imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kPrimaryColor,
          content: Text(
            "Profile updated successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              style: TextStyle(color: Colors.red),
              "Please log in again to update your information.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              style: TextStyle(color: Colors.red),
              "Error: ${e.message}",
            ),
          ),
        );
      }
    }
  }

  bool _obscurePassword = true;

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipOval(
                  child:
                      imageUrl != null
                          ? Image.network(
                            imageUrl!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                          : _imageFile != null
                          ? Image.memory(
                            _imageFile!.readAsBytesSync(),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                          : const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF3C6845),
                            ),
                          ),
                ),

                Positioned(
                  bottom: 0,
                  child: InkWell(
                    onTap: () async {
                      await _pickImage();
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF3C6845),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Name"),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: emailController,
            readOnly: true,
            decoration: InputDecoration(labelText: "Email"),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelText: "Password",
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleVisibility,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C6845),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black26),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto Slab',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } catch (e) {
                  print(e);
                }
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
