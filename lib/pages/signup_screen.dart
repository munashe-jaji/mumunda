import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/login_screen.dart';
import 'dart:typed_data';

class SignUpScreen extends StatefulWidget {
  static String id = 'signup_screen';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  int _stepIndex = 0;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  final _farmNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  String? _selectedFarmingType;

  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  Uint8List? _logoBytes;
  String? _logoFileName;
  String? _logoUrl;

  bool _isFarmer = false;
  bool _isExhibitor = false;

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _logoBytes = result.files.single.bytes;
        _logoFileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadLogo(String uid) async {
    if (_logoBytes == null) return;
    final ref = FirebaseStorage.instance.ref().child('logos/$uid.jpg');
    await ref.putData(_logoBytes!, SettableMetadata(contentType: 'image/jpeg'));
    _logoUrl = await ref.getDownloadURL();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      User? user = await _auth.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _locationController.text.trim(),
        farmName: _isFarmer ? _farmNameController.text.trim() : null,
        farmSize: _isFarmer ? _farmSizeController.text.trim() : null,
        farmingType: _isFarmer ? _selectedFarmingType : null,
        contact: _isExhibitor ? _contactController.text.trim() : null,
        description: _isExhibitor ? _descriptionController.text.trim() : null,
        logo: null,
        isFarmer: _isFarmer,
        isExhibitor: _isExhibitor,
      );

      if (user != null) {
        await _uploadLogo(user.uid);

        final collection = FirebaseFirestore.instance
            .collection(_isFarmer ? 'farmers' : 'exhibitors');

        await collection.doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
          if (_isFarmer) ...{
            'farmName': _farmNameController.text.trim(),
            'farmSize': _farmSizeController.text.trim(),
            'farmingType': _selectedFarmingType,
          },
          if (_isExhibitor) ...{
            'contact': _contactController.text.trim(),
            'description': _descriptionController.text.trim(),
            'logo': _logoUrl,
            'status': 'pending',
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

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscure = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.green[50],
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        obscureText: obscure,
        validator: validator ??
            (value) =>
                value == null || value.isEmpty ? 'Enter your $labelText' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Farmer'),
                      selectedColor: Colors.green,
                      selected: _isFarmer,
                      onSelected: (value) {
                        setState(() {
                          _isFarmer = value;
                          _isExhibitor = !value;
                          _stepIndex = 0;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Exhibitor'),
                      selectedColor: Colors.green,
                      selected: _isExhibitor,
                      onSelected: (value) {
                        setState(() {
                          _isExhibitor = value;
                          _isFarmer = !value;
                          _stepIndex = 0;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Stepper(
                      currentStep: _stepIndex,
                      onStepContinue: () {
                        if (_stepIndex < 3) {
                          setState(() => _stepIndex++);
                        } else {
                          _signUp();
                        }
                      },
                      onStepCancel: () {
                        if (_stepIndex > 0) setState(() => _stepIndex--);
                      },
                      controlsBuilder: (context, details) {
                        return Row(
                          children: [
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: Text(_stepIndex < 3 ? "Next" : "Sign Up"),
                            ),
                            const SizedBox(width: 10),
                            if (_stepIndex > 0)
                              OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green[800],
                                ),
                                child: const Text("Back"),
                              ),
                          ],
                        );
                      },
                      steps: [
                        Step(
                          title: const Text("Account Info"),
                          content: Column(
                            children: [
                              _buildTextField(_emailController, "Email"),
                              _buildTextField(_passwordController, "Password",
                                  obscure: true),
                            ],
                          ),
                        ),
                        Step(
                          title: const Text("Personal Info"),
                          content: Column(
                            children: [
                              _buildTextField(_nameController, "Name"),
                              _buildTextField(_phoneController, "Phone"),
                              _buildTextField(_locationController, "Location"),
                            ],
                          ),
                        ),
                        Step(
                          title: const Text("Farmer Info"),
                          content: _isFarmer
                              ? Column(
                                  children: [
                                    _buildTextField(
                                        _farmNameController, "Farm Name"),
                                    _buildTextField(
                                        _farmSizeController, "Farm Size"),
                                    DropdownButtonFormField<String>(
                                      value: _selectedFarmingType,
                                      items: [
                                        'Crop Farming',
                                        'Livestock',
                                        'Mixed Farming',
                                        'Horticulture'
                                      ]
                                          .map((type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(type),
                                              ))
                                          .toList(),
                                      onChanged: (value) => setState(
                                          () => _selectedFarmingType = value),
                                      decoration: InputDecoration(
                                        labelText: "Farming Type",
                                        filled: true,
                                        fillColor: Colors.green[50],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      validator: (value) =>
                                          _isFarmer && value == null
                                              ? "Select your farming type"
                                              : null,
                                    ),
                                  ],
                                )
                              : const Text("Not applicable"),
                        ),
                        Step(
                          title: const Text("Exhibitor Info"),
                          content: _isExhibitor
                              ? Column(
                                  children: [
                                    _buildTextField(
                                        _contactController, "Contact"),
                                    _buildTextField(
                                        _descriptionController, "Description"),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed: _pickLogo,
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text("Upload Logo"),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                    ),
                                    if (_logoFileName != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          "Selected: $_logoFileName",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.green),
                                        ),
                                      ),
                                  ],
                                )
                              : const Text("Not applicable"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, LoginScreen.id);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
