import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});
  static String id = 'marketplace_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
      ),
      body: const Center(
        child: Text('Welcome to the Marketplace Page!'),
      ),
    );
  }
}
