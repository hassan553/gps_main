import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gps_main/core/constants.dart';
import 'package:gps_main/features/auth/register_screen.dart';
import 'package:gps_main/features/home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4EDE5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Transform.scale(
                scale: 2,
                child: Image.asset(
                  'assets/icon.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3C2C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Fill out the information below in order\nto access your account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: const Color(0xFFF2F5F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFF2F5F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child:
                          isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF557959),
                                ),
                              )
                              : ElevatedButton(
                                onPressed: () async {
                                  final email = emailController.text.trim();
                                  final password = passwordController.text;

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: kPrimaryColor,
                                        content: Text(
                                          'Please enter both email and password',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    final credential = await FirebaseAuth
                                        .instance
                                        .signInWithEmailAndPassword(
                                          email: email,
                                          password: password,
                                        );

                                    // Optionally fetch user data from Firestore
                                    final userDoc =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(credential.user!.uid)
                                            .get();

                                    if (userDoc.exists) {
                                      final userData = userDoc.data();
                                      print("Logged in user data: $userData");
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: kPrimaryColor,
                                        content: Text(
                                          'Login successful',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MainScreen(),
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    String message = 'Login failed';
                                    if (e.code == 'user-not-found') {
                                      message = 'No user found for this email.';
                                    } else if (e.code == 'wrong-password') {
                                      message = 'Incorrect password.';
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          message,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          'Something went wrong: $e',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF557959),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Sign Up here",
                                style: const TextStyle(
                                  color: Color(0xFF3478F6),
                                  fontWeight: FontWeight.bold,
                                ),
                                // Add onTap gesture if needed
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
