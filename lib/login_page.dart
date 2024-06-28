import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projek_uas/customerpage2.dart'; // Update the import path

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/api/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          // Login successful
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerHomePage2()), // Update to CustomerHomePage2
          );
        } else {
          // Login failed
          setState(() {
            _errorMessage =
                json.decode(response.body)['message'] ?? 'Login failed';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Login',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please login to your account.'),
              SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Forgot password logic
                  },
                  child: Text('Forgot Password?'),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _login,
                child: Text('LOGIN'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16),
              Text('OR'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.facebook),
                    onPressed: () {
                      // Facebook login logic
                    },
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.alternate_email),
                    onPressed: () {
                      // Twitter login logic
                    },
                  ),
                ],
              ),
              SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
