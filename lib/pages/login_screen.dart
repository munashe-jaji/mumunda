import 'package:flutter/material.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mis/admin/adminscreen.dart';
import 'package:mis/exhibitor/exhibitorscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = await _auth.signInWithEmailAndPassword(email, password);
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = userDoc.data()?['role'] ?? 'user';

        // Automatically navigate to the appropriate page
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminScreen(email: email),
              ),
            );
          } else if (role == 'exhibitor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ExhibitorScreen(email: email),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(email: email),
              ),
            );
          }
        }
      } else {
        _showErrorDialog('Invalid email or password.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Make sure to add your logo image in the assets folder and update the path accordingly
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}