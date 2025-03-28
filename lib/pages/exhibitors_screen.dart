import 'package:flutter/material.dart';

class ExhibitorsScreen extends StatelessWidget {
  const ExhibitorsScreen({super.key});
  static String id = 'exhibitors_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibitors'),
      ),
      body: const Center(
        child: Text('Welcome to the Exhibitors Page!'),
      ),
    );
  }
}
