import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddProductScreen extends StatelessWidget {
  final TextEditingController imageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController sellerController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  AdminAddProductScreen({super.key});

  Future<void> addProduct({
    required String image,
    required String name,
    required String description,
    required double price,
    required String seller,
    required int quantity,
    required String category,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'image': image,
        'name': name,
        'description': description,
        'price': price,
        'seller': seller,
        'quantity': quantity,
        'category': category,
      });
      print('Product added successfully');
    } catch (e) {
      print('Failed to add product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: imageController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sellerController,
              decoration: InputDecoration(labelText: 'Seller'),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addProduct(
                  image: imageController.text,
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.parse(priceController.text),
                  seller: sellerController.text,
                  quantity: int.parse(quantityController.text),
                  category: categoryController.text,
                );
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
