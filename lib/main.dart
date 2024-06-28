import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_uas/custommerpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AM Market',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[100],
          title: Text(
            'AM Market',
            style: GoogleFonts.acme(),
          ),
        ),
        body: CustomerHomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
