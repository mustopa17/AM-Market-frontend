import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';

class EditProductForm extends StatefulWidget {
  final Product product;

  EditProductForm({required this.product});

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _imageController = TextEditingController(text: widget.product.image);
    _categoryController = TextEditingController(text: widget.product.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _editProduct();
                  }
                },
                child: Text('Edit Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProduct() async {
    final url =
        Uri.parse('http://127.0.0.1:8000/api/products/${widget.product.id}');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'title': _titleController.text,
      'price': double.parse(_priceController.text),
      'description': _descriptionController.text,
      'image': _imageController.text,
      'category': _categoryController.text,
    });

    final response = await http.put(url, headers: headers, body: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final updatedProduct = Product.fromJson(json.decode(response.body));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product updated successfully'),
      ));
      Navigator.pop(context,
          updatedProduct); // Kembalikan produk yang diperbarui ke layar Home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update product'),
      ));
    }
  }
}
