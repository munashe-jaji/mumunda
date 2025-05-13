import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mis/services/auth_service.dart';
import 'package:mis/pages/login_screen.dart';
import 'package:web/web.dart' as web;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green, // Primary color (green)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green, // Green AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Green buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: Colors.greenAccent, // Accent color (lighter green)
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
              color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
          bodyMedium:
              TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 16),
        ),
      ),
      home: const AdminScreen(email: 'admin@example.com'),
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
            indicatorColor: Colors.white, // Tab indicator color
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: TabBarView(
            children: [
              ManageEventsPage(),
              ApproveExhibitorsPage(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEventScreen()),
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
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Event Name')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Schedule')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: events.map((event) {
                    final data = event.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['name'] ?? '')),
                      DataCell(Text(data['date'] ?? '')),
                      DataCell(Text(data['location'] ?? '')),
                      DataCell(data['schedule'] != null
                          ? InkWell(
                              onTap: () =>
                                  web.window.open(data['schedule'], '_blank'),
                              child: const Text('View PDF',
                                  style: TextStyle(color: Colors.blue)),
                            )
                          : const Text('No PDF')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(event.id)
                                  .delete();
                            },
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
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _guestsController = TextEditingController();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();

  PlatformFile? _pdfFile;
  String? pdfUrl;

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() => _pdfFile = result.files.first);
    }
  }

  Future<void> _uploadEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_pdfFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('schedules/${_pdfFile!.name}');
          final uploadTask = storageRef.putData(_pdfFile!.bytes!);

          // Log the upload task state
          uploadTask.snapshotEvents.listen((event) {
            print('Task state: ${event.state}');
            print(
                'Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
          });

          final snapshot = await uploadTask.whenComplete(() {});
          pdfUrl = await snapshot.ref.getDownloadURL();
          print('PDF uploaded successfully: $pdfUrl');
        }

        await FirebaseFirestore.instance.collection('events').add({
          'contact': _contactController.text,
          'description': _descriptionController.text,
          'guests': _guestsController.text,
          'location': _locationController.text,
          'name': _nameController.text,
          'date': _dateController.text,
          'schedule': pdfUrl,
        });

        Navigator.pop(context);
      } catch (e) {
        print('Error uploading event: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add event: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_dateController, 'Date'),
              _buildTextField(_locationController, 'Location'),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(_contactController, 'Contact'),
              _buildTextField(_guestsController, 'Guests'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickPDF,
                child: const Text('Upload Schedule PDF'),
              ),
              if (_pdfFile != null) Text(_pdfFile!.name),
              const SizedBox(height: 16),
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: _validate,
      ),
    );
  }

  String? _validate(String? value) =>
      (value == null || value.isEmpty) ? 'This field is required' : null;
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('exhibitors')
                .where('status', isEqualTo: 'pending') // Filter by status
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final exhibitors = snapshot.data!.docs;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: exhibitors.map((ex) {
                    final data = ex.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['name'] ?? '')),
                      DataCell(Text(data['email'] ?? '')),
                      DataCell(Text(data['phone'] ?? '')),
                      DataCell(Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('exhibitors')
                                  .doc(ex.id)
                                  .update({'status': 'approved'});
                            },
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              // Delete the exhibitor's account and data
                              await FirebaseFirestore.instance
                                  .collection('exhibitors')
                                  .doc(ex.id)
                                  .delete();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Reject'),
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
