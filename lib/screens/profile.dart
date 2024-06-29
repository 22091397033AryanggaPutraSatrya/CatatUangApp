import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import the package

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk memperbarui data profil pertama kali
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/CatatApp/users/read.php?id=$userId'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _username = userData['username'];
          _email = userData['email'];
        });
      } else {

      }
    } catch (e) {
      print('Error fetching profile data: $e');

    }
  }

  // Method to handle logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage(); // Initialize the secure storage
    await prefs.clear(); // Clear SharedPreferences
    await storage.deleteAll(); // Clear secure storage
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout method when pressed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Hai! $_username. Terimakasih telah menggunakan aplikasi Catatan Keuangan Harian ini. Anda dapat memberikan kritik dan saran kepada kami :)',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $_email',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
