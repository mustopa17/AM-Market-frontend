import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  bool isEditing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token is null');
      }
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          username = userData['name'];
          email = userData['email'];
          phoneNumber = userData['phone_number'] ?? '';
          address = userData['address'] ?? '';
        });
      } else {
        throw Exception(' ${response.statusCode}');
      }
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> handleLogout() async {
    try {
      await storage.delete(key: 'auth_token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error logging out: $e';
      });
    }
  }

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final token = await storage.read(key: 'auth_token');
        if (token == null) {
          throw Exception('');
        }
        final response = await http.put(
          Uri.parse('http://localhost:8000/api/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': username,
            'email': email,
            'phone_number': phoneNumber,
            'address': address,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data Successfully Saved')),
          );
          _fetchProfileData(); // Fetch data again after successful save
        } else {
          throw Exception('');
        }
      } catch (e) {
        setState(() {
          _errorMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'My Profile',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                if (!isEditing) ...[
                  Text(
                    username,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    phoneNumber.isNotEmpty ? 'Phone: $phoneNumber' : 'Phone: -',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    address.isNotEmpty ? 'Address: $address' : 'Address: -',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    child: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: handleLogout,
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    initialValue: username,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        username = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
                              .hasMatch(value)) {
                        return 'Please enter a valid email address ending with @gmail.com.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: phoneNumber,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Please enter a valid English phone number.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: address,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        address = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await updateProfile();
                        setState(() {
                          isEditing = false;
                        });
                      }
                    },
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
