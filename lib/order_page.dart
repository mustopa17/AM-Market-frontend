// lib/order.dart
import 'package:flutter/material.dart';

class Order {
  final int id;
  final String title;
  final double price;
  final int quantity;

  Order({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      title: json['title'],
      price: double.parse(json['price']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }
}

// lib/order_page.dart

class OrderPage extends StatelessWidget {
  final List<Order> orders;

  OrderPage({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'No orders yet.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: Text(
                        '${order.quantity}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      order.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Quantity: ${order.quantity}',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      '\$${order.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
