import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  Future<void> addToCart() async {
    final url = Uri.parse('http://localhost:8000/api/cart-items');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': widget.product.title,
        'price': widget.product.price,
        'image_path': widget.product.image,
        'quantity': quantity,
      }),
    );

    print(response.statusCode);
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star_border, color: Colors.amber),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.category),
                      SizedBox(width: 8),
                      Text('Category: ${widget.product.category}'),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                        child: Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: addToCart,
            child: Text(
              'Add to Cart - \$${(widget.product.price * quantity).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
