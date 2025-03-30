import 'package:flutter/material.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/login_screen.dart';

class AdminScreen extends StatelessWidget {
  final String email;

  const AdminScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manage Products'),
              Tab(text: 'Manage Exhibitors'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  children: [
                    ManageProductsPage(),
                    ManageExhibitorsPage(),
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

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Manage Products'),
          ElevatedButton(
            onPressed: () {
              // Add product logic
            },
            child: const Text('Add Product'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update product logic
            },
            child: const Text('Update Product'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete product logic
            },
            child: const Text('Delete Product'),
          ),
        ],
      ),
    );
  }
}

class ManageExhibitorsPage extends StatelessWidget {
  const ManageExhibitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Manage Exhibitors'),
          ElevatedButton(
            onPressed: () {
              // Add exhibitor logic
            },
            child: const Text('Add Exhibitor'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update exhibitor logic
            },
            child: const Text('Update Exhibitor'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete exhibitor logic
            },
            child: const Text('Delete Exhibitor'),
          ),
        ],
      ),
    );
  }
}
