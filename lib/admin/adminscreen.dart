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
              Tab(text: 'Manage Events'),
              Tab(text: 'Approve Exhibitors'),
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
                    ManageEventsPage(),
                    ApproveExhibitorsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddEventOptions(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddEventOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Add Event'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Add Event screen
              },
            ),
          ],
        );
      },
    );
  }
}

class ManageEventsPage extends StatelessWidget {
  const ManageEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Manage Events',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Event Name')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Event 1')),
                  const DataCell(Text('2023-10-01')),
                  const DataCell(Text('Location 1')),
                  DataCell(Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Update event logic
                        },
                        child: const Text('Update'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Delete event logic
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  )),
                ]),
                // Add more DataRow here for more events
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ApproveExhibitorsPage extends StatelessWidget {
  const ApproveExhibitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Approve Exhibitors',
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
                          // Approve exhibitor logic
                        },
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Reject exhibitor logic
                        },
                        child: const Text('Reject'),
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
