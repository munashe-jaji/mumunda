import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/login_screen.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdminScreen(email: 'admin@example.com'),
    );
  }
}

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEventScreen()),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data!.docs;

              return SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Event Name')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: events.map((event) {
                    return DataRow(cells: [
                      DataCell(Text(event['name'])),
                      DataCell(Text(event['date'])),
                      DataCell(Text(event['location'])),
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
                    ]);
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  PlatformFile? _pdfFile;
  String? pdfUrl;

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = result.files.first;
      });
    }
  }

  Future<void> _uploadEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_pdfFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('schedules/${_pdfFile!.name}');
          final uploadTask = storageRef.putFile(File(_pdfFile!.path!));
          final snapshot = await uploadTask.whenComplete(() {});
          pdfUrl = await snapshot.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('events').add({
          'contact': _contactController.text,
          'description': _descriptionController.text,
          'guests': _guestsController.text,
          'location': _locationController.text,
          'name': _nameController.text,
          'schedule': pdfUrl,
        });

        Navigator.pop(context);
      } catch (e) {
        print('Error uploading event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _guestsController,
                decoration: const InputDecoration(labelText: 'Guests'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter guests';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickPDF,
                child: const Text('Upload Schedule (PDF)'),
              ),
              if (_pdfFile != null) Text(_pdfFile!.name),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadEvent,
                child: const Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApproveExhibitorsPage extends StatefulWidget {
  const ApproveExhibitorsPage({super.key});

  @override
  _ApproveExhibitorsPageState createState() => _ApproveExhibitorsPageState();
}

class _ApproveExhibitorsPageState extends State<ApproveExhibitorsPage> {
  final List<String> availableBooths = ['Booth 1', 'Booth 2', 'Booth 3'];
  final List<Map<String, String>> exhibitors = [
    {
      'name': 'Exhibitor 1',
      'contact': '123-456-7890',
      'email': 'exhibitor1@example.com'
    },
    // Add more exhibitors here
  ];

  void _approveExhibitor(int index) {
    if (availableBooths.isNotEmpty) {
      final assignedBooth = availableBooths.removeAt(0);
      setState(() {
        exhibitors[index]['booth'] = assignedBooth;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Exhibitor approved and assigned to $assignedBooth')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available booths')),
      );
    }
  }

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
              rows: exhibitors.map((exhibitor) {
                final index = exhibitors.indexOf(exhibitor);
                return DataRow(cells: [
                  DataCell(Text(exhibitor['name']!)),
                  DataCell(Text(exhibitor['contact']!)),
                  DataCell(Text(exhibitor['email']!)),
                  DataCell(Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _approveExhibitor(index);
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
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
