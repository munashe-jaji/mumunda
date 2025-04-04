import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  static String id = 'signup_screen';

  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _farmingTypeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isFarmer = false;
  bool _isExhibitor = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      User? user = await _auth.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _phoneController.text,
        _locationController.text,
        farmName: _isFarmer ? _farmNameController.text : null,
        farmSize: _isFarmer ? _farmSizeController.text : null,
        farmingType: _isFarmer ? _farmingTypeController.text : null,
        contact: _isExhibitor ? _contactController.text : null,
        description: _isExhibitor ? _descriptionController.text : null,
        logo: _isExhibitor ? _logoController.text : null,
        isFarmer: _isFarmer,
        isExhibitor: _isExhibitor,
      );

      if (user != null) {
        // Save user details to Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference collection = _isFarmer
            ? firestore.collection('farmers')
            : firestore.collection('exhibitors');

        await collection.doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          if (_isFarmer) ...{
            'farmName': _farmNameController.text,
            'farmSize': _farmSizeController.text,
            'farmingType': _farmingTypeController.text,
          },
          if (_isExhibitor) ...{
            'contact': _contactController.text,
            'description': _descriptionController.text,
            'logo': _logoController.text,
          },
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful!')),
        );

        Navigator.pushReplacementNamed(context, LoginScreen.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    }
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      bool obscureText = false,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      obscureText: obscureText,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $labelText';
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CheckboxListTile(
                title: const Text('Farmer'),
                value: _isFarmer,
                onChanged: (bool? value) {
                  setState(() {
                    _isFarmer = value!;
                    _isExhibitor = !value;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Exhibitor'),
                value: _isExhibitor,
                onChanged: (bool? value) {
                  setState(() {
                    _isExhibitor = value!;
                    _isFarmer = !value;
                  });
                },
              ),
              if (_isFarmer) ...[
                _buildTextField(
                    controller: _emailController, labelText: 'Email'),
                _buildTextField(
                    controller: _farmNameController, labelText: 'Farm Name'),
                _buildTextField(
                    controller: _farmSizeController, labelText: 'Farm Size'),
                _buildTextField(
                    controller: _farmingTypeController,
                    labelText: 'Farming Type'),
                _buildTextField(
                    controller: _locationController, labelText: 'Location'),
                _buildTextField(controller: _nameController, labelText: 'Name'),
                _buildTextField(
                    controller: _phoneController, labelText: 'Phone'),
                _buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true),
              ] else if (_isExhibitor) ...[
                _buildTextField(
                    controller: _emailController, labelText: 'Email'),
                _buildTextField(
                    controller: _contactController, labelText: 'Contact'),
                _buildTextField(
                    controller: _descriptionController,
                    labelText: 'Description'),
                _buildTextField(
                    controller: _locationController, labelText: 'Location'),
                _buildTextField(controller: _logoController, labelText: 'Logo'),
                _buildTextField(controller: _nameController, labelText: 'Name'),
                _buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
