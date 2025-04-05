import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExhibitorScreen(email: 'exhibitor@example.com'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Add your sign out logic here
            },
          ),
        ],
      ),
      body: ProductsPage(email: email),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddProductsPage(email: email)),
          );
        },
        child: const Icon(Icons.add),
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Quantity')),
            ],
            rows: products.map((product) {
              final data = product.data() as Map<String, dynamic>;
              return DataRow(cells: [
                DataCell(Text(data['name'] ?? '')),
                DataCell(Text(data['price'] ?? '')),
                DataCell(Text(data['description'] ?? '')),
                DataCell(Text(data['quantity'] ?? '')),
              ]);
            }).toList(),
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
  final _exhibitorController = TextEditingController();

  PlatformFile? _imageFile;
  String? imageUrl;

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
          final uploadTask = storageRef.putData(_imageFile!.bytes!);

          final snapshot = await uploadTask.whenComplete(() {});
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'quantity': _quantityController.text,
          'exhibitor': _exhibitorController.text,
          'image': imageUrl,
          'email': widget.email, // Use the email passed to the widget
        });

        Navigator.pop(context); // This will navigate back to ExhibitorScreen
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value!.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) => value!.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _exhibitorController,
                decoration: const InputDecoration(labelText: 'Exhibitor'),
                validator: (value) => value!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _pickImage, child: const Text('Upload Image')),
            if (_imageFile != null) Text(_imageFile!.name),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _uploadProduct, child: const Text('Add Product')),
          ],
        ),
      ),
    );
  }
}
