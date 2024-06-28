import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'order_page.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  List<Order> orders = []; // Daftar pesanan yang sudah di-checkout
  bool isLoading = true;
  int total = 0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/cart-items'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          cartItems = data.map((item) => CartItem.fromJson(item)).toList();
          calculateTotal();
          isLoading = false;
        });
      } else {
        print('Failed to load cart items: ${response.statusCode}');
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart items. Please try again.')),
      );
    }
  }

  void calculateTotal() {
    total = cartItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity).toInt());
  }

  Future<void> updateCartItem(CartItem item) async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/api/cart-items/${item.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    if (response.statusCode == 200) {
      fetchCartItems();
    } else {
      throw Exception('Failed to update cart item');
    }
  }

  Future<void> deleteCartItem(int id) async {
    final response = await http
        .delete(Uri.parse('http://localhost:8000/api/cart-items/$id'));
    if (response.statusCode == 204) {
      fetchCartItems();
    } else {
      throw Exception('Failed to delete cart item');
    }
  }

  void checkout() {
    // Tambahkan logika checkout di sini
    // Contoh: Tambahkan pesanan ke daftar orders
    setState(() {
      orders = cartItems.map((item) {
        return Order(
          id: item.id,
          title: item.title,
          price: item.price,
          quantity: item.quantity,
        );
      }).toList();
      cartItems.clear(); // Kosongkan keranjang setelah checkout
      total = 0; // Reset total setelah checkout
    });

    // Navigasi ke halaman OrderPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(orders: orders),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchCartItems,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(child: Text('Your cart is empty'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return CartItemWidget(
                            item: cartItems[index],
                            onQuantityChanged: (newQuantity) {
                              cartItems[index].quantity = newQuantity;
                              updateCartItem(cartItems[index]);
                            },
                            onDelete: () => deleteCartItem(cartItems[index].id),
                          );
                        },
                      ),
                    ),
                    TotalAndCheckout(
                      total: total,
                      onCheckout: checkout,
                    ),
                  ],
                ),
    );
  }
}

class CartItem {
  final int id;
  final String title;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      title: json['title'],
      price: double.parse(json['price']),
      imagePath: json['image_path'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image_path': imagePath,
      'quantity': quantity,
    };
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;

  CartItemWidget(
      {required this.item,
      required this.onQuantityChanged,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Image.network(item.imagePath, width: 60, height: 60),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextStyle(fontSize: 16)),
                  Text('\$${item.price}', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: item.quantity > 1
                  ? () => onQuantityChanged(item.quantity - 1)
                  : null,
            ),
            Text(item.quantity.toString(), style: TextStyle(fontSize: 16)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => onQuantityChanged(item.quantity + 1),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class TotalAndCheckout extends StatelessWidget {
  final int total;
  final VoidCallback onCheckout;

  TotalAndCheckout({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Handle adding coupon code
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Add Coupon Code',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$$total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCheckout,
            child: Text(
              'Check Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increased font size
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A4AD4),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
