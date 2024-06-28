import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'addproduct.dart';
import 'update.dart';
import 'delete.dart'; // Import the delete dialog file

class SellerPage extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<SellerPage> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductForm(),
                ),
              );

              if (newProduct != null) {
                setState(() {
                  _products.add(newProduct);
                });
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: Image.network(product.image),
            title: Text(product.title),
            subtitle: Text('\$${product.price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final updatedProduct = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductForm(product: product),
                      ),
                    );

                    if (updatedProduct != null) {
                      setState(() {
                        _products[index] = updatedProduct;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(product.id, index),
                ),
              ],
            ),
            onTap: () async {
              final updatedProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductForm(product: product),
                ),
              );

              if (updatedProduct != null) {
                setState(() {
                  _products[index] = updatedProduct;
                });
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _products = data.map((json) => Product.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> _confirmDelete(int productId, int index) async {
    final bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog();
      },
    );

    if (deleteConfirmed == true) {
      _deleteProduct(productId, index);
    }
  }

  Future<void> _deleteProduct(int productId, int index) async {
    final response = await http
        .delete(Uri.parse('http://localhost:8000/api/products/$productId'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        _products.removeAt(index);
      });
    } else {
      throw Exception('Failed to delete product');
    }
  }
}
