import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  static String id = 'map_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/mapbc.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay (optional for text visibility)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
            ),
          ),
          // Page content
          const Center(
            child: Text(
              'Welcome to the Map Page!',
              style: TextStyle(
                color: Colors.white, // Ensure text is visible
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}