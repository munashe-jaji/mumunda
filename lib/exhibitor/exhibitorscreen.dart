import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mis/pages/login_screen.dart';

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
      title: 'Green Exhibitor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ExhibitorScreen(email: 'sirmadhilo@grains.com'),
    );
  }
}

class ExhibitorScreen extends StatelessWidget {
  final String email;

  const ExhibitorScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibitor Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: ProductsPage(email: email),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductsPage(email: email),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  final String email;

  const ProductsPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(Colors.green[100]),
              columns: const [
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Quantity')),
              ],
              rows: products.map((product) {
                final data = product.data() as Map<String, dynamic>;
                final imageUrl = data['image'];
                final price = data['price'];
                final quantity = data['quantity'];

                return DataRow(cells: [
                  DataCell(imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, color: Colors.red),
                        )
                      : const Icon(Icons.image_not_supported)),
                  DataCell(Text('${data['name'] ?? ''}')),
                  DataCell(Text(price != null
                      ? double.tryParse(price.toString())?.toStringAsFixed(2) ??
                          ''
                      : '')),
                  DataCell(Text('${data['description'] ?? ''}')),
                  DataCell(Text(quantity != null ? quantity.toString() : '')),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class AddProductsPage extends StatefulWidget {
  final String email;

  const AddProductsPage({super.key, required this.email});

  @override
  State<AddProductsPage> createState() => _AddProductsPageState();
}

class _AddProductsPageState extends State<AddProductsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  PlatformFile? _imageFile;
  String? imageUrl;
  String? exhibitorName;

  @override
  void initState() {
    super.initState();
    fetchExhibitorName();
  }

  Future<void> fetchExhibitorName() async {
    final doc = await FirebaseFirestore.instance
        .collection('exhibitors')
        .where('email', isEqualTo: widget.email)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      setState(() {
        exhibitorName = doc.docs.first.data()['name'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibitor not found.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _imageFile = result.files.first);
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('products/${_imageFile!.name}');
          final uploadTask = storageRef.putData(
            _imageFile!.bytes!,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final snapshot = await uploadTask.whenComplete(() {});
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'quantity': _quantityController.text,
          'exhibitor': exhibitorName ?? '',
          'image': imageUrl,
          'email': widget.email,
          'status': 'pending',
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          validator: (value) => value!.isEmpty ? '$label is required' : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.green[50],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                exhibitorName != null
                    ? 'Exhibitor: $exhibitorName'
                    : 'Loading exhibitor...',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildTextField('Product Name', _nameController),
              buildTextField('Price', _priceController),
              buildTextField('Description', _descriptionController),
              buildTextField('Quantity', _quantityController),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _pickImage,
                label: const Text('Select Image'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Selected: ${_imageFile!.name}'),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                onPressed: exhibitorName == null ? null : _uploadProduct,
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
