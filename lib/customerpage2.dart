import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:projek_uas/cartpage.dart';
import 'package:projek_uas/custommerpage.dart';
import 'package:projek_uas/detailpage.dart';
import 'package:projek_uas/myProfile.dart'; // Import the MyProfilePage
import 'package:projek_uas/product.dart';
import 'package:projek_uas/sellerpage.dart';

class CustomerHomePage2 extends StatefulWidget {
  @override
  _CustomerHomePage2State createState() => _CustomerHomePage2State();
}

class _CustomerHomePage2State extends State<CustomerHomePage2> {
  List<Product> products = [];
  bool isLoggedIn = false;
  String username = '';
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await storage.read(key: 'auth_token');
    print('Token: $token'); // Debug log
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
      fetchUsername();
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  Future<void> fetchUsername() async {
    try {
      final token = await storage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          username = userData['name'];
        });
      } else if (response.statusCode == 401) {
        print('Unauthorized: Please log in again');
        handleLogout();
      } else {
        print('Failed to fetch username. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/products'));
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        setState(() {
          products =
              productsJson.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> handleLogout() async {
    await storage.delete(key: 'auth_token');
    setState(() {
      isLoggedIn = false;
      username = '';
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CustomerHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        automaticallyImplyLeading: false, // Remove the back button
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SellerPage()));
          },
          child: Text(
            'Become a Seller',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
        actions: [
          if (isLoggedIn)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 15,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  username,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    switch (result) {
                      case 'account':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyProfilePage()),
                        );
                        break;
                      case 'orders':
                        // TODO: Navigate to orders page
                        break;
                      case 'logout':
                        handleLogout();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'account',
                      child: Text('Akun Saya'),
                    ),
                    PopupMenuItem<String>(
                      value: 'orders',
                      child: Text('Pesanan Saya'),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Log Out'),
                    ),
                  ],
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ],
            )
          else
            Row(
              children: [
                TextButton(
                  child: Text(
                    'My Profile',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyProfilePage()),
                    );
                  },
                ),
                TextButton(
                  child: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: handleLogout,
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(),
                SizedBox(height: 10),
                SizedBox(height: 20),
                Text('All items',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                PopularItems(products),
                SizedBox(height: 30),
                Text('Newest',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                NewestItems(products),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        },
        child: Icon(Icons.shopping_cart),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'What would you like to have?',
        prefixIcon: Icon(Icons.search),
        suffixIcon: Icon(Icons.filter_list),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String name;
  final String imagePath;

  CategoryItem(this.name, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }
}

class PopularItems extends StatelessWidget {
  final List<Product> products;
  PopularItems(this.products);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return FoodItem(products[index]);
        },
      ),
    );
  }
}

class NewestItems extends StatelessWidget {
  final List<Product> products;

  NewestItems(this.products);

  @override
  Widget build(BuildContext context) {
    if (products.isNotEmpty) {
      return FoodItem(products.last);
    } else {
      return SizedBox(); // Return an empty widget if there are no products
    }
  }
}

class FoodItem extends StatelessWidget {
  final Product product;

  FoodItem(this.product);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(product.image,
                  height: 100, width: 150, fit: BoxFit.cover),
            ),
            SizedBox(height: 8),
            Text(
              product.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.favorite_border, color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
