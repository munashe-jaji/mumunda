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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddOptions(context);
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Add Product'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Add Product screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Exhibitor'),
              onTap: () {
                Navigator.pop(context);
                _showAddExhibitorForm(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddExhibitorForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String contact = '';
    String description = '';
    String location = '';
    String logo = '';
    String name = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Exhibitor'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contact'),
                    onSaved: (value) {
                      contact = value ?? '';
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) {
                      description = value ?? '';
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    onSaved: (value) {
                      location = value ?? '';
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Logo'),
                    onSaved: (value) {
                      logo = value ?? '';
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onSaved: (value) {
                      name = value ?? '';
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Save exhibitor logic
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Manage Products',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Seller')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Image.network('https://via.placeholder.com/50')),
                  const DataCell(Text('Product 1')),
                  const DataCell(Text('Description 1')),
                  const DataCell(Text('\$10')),
                  const DataCell(Text('Seller 1')),
                  const DataCell(Text('100')),
                  DataCell(Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add to Wishlist logic
                        },
                        child: const Text('Add to Wishlist'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Inquire logic
                        },
                        child: const Text('Inquire'),
                      ),
                    ],
                  )),
                ]),
                // Add more DataRow here for more products
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ManageExhibitorsPage extends StatelessWidget {
  const ManageExhibitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Manage Exhibitors',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Exhibitor 1')),
                  const DataCell(Text('123-456-7890')),
                  const DataCell(Text('exhibitor1@example.com')),
                  DataCell(Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Update exhibitor logic
                        },
                        child: const Text('Update'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Delete exhibitor logic
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  )),
                ]),
                // Add more DataRow here for more exhibitors
              ],
            ),
          ),
        ),
      ],
    );
  }
}
