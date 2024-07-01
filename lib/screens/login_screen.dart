import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    checkLoggedInStatus();
  }

  Future<void> checkLoggedInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    if (userId != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/CatatApp/users/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _email,
          'password': _password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', responseBody['user_id']);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
        _showErrorDialog(responseBody['message']);
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kesalahan'),
          content: Text('Email atau Password yang Anda masukkan salah.'),
          actions: <Widget>[
            TextButton(
              child: Text('Coba Lagi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:  true,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState?.save();
                    _login();
                  },
                  child: Text('MASUK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Belum punya Akun? Daftar disini.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
