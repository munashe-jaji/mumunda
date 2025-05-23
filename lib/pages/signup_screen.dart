import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/login_screen.dart';

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
  final _farmingTypeController = TextEditingController();

  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isFarmer = false;
  bool _isExhibitor = false;
  bool _obscurePassword = true;

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
        farmingType: _isFarmer ? _farmingTypeController.text.trim() : null,
        contact: _isExhibitor ? _contactController.text.trim() : null,
        description: _isExhibitor ? _descriptionController.text.trim() : null,
        logo: null,
        isFarmer: _isFarmer,
        isExhibitor: _isExhibitor,
      );

      if (user != null) {
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
            'farmingType': _farmingTypeController.text.trim(),
          },
          if (_isExhibitor) ...{
            'contact': _contactController.text.trim(),
            'description': _descriptionController.text.trim(),
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

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    final isPasswordField = labelText.toLowerCase() == 'password';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure ? _obscurePassword : false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.green[50],
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
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
                              _buildTextField(
                                _passwordController,
                                "Password",
                                obscure: true,
                              ),
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
                                    _buildTextField(
                                      _farmingTypeController,
                                      "Farming Type",
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
