import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalPemasukan = 0.0;
  double totalPengeluaran = 0.0;
  double sisaUang = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDataPemasukan(); // Call the method to fetch pemasukan data
    fetchDataPengeluaran(); // Call the method to fetch pengeluaran data
    // Panggil metode untuk memperbarui data pertama kali
    fetchFinancialData();
    // Mulai timer untuk memperbarui data setiap 1 detik
    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchFinancialData();
      fetchDataPemasukan(); // Call the method to fetch pemasukan data
      fetchDataPengeluaran(); // Call the method to fetch pengeluaran data
    });
  }

  Future<void> fetchFinancialData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      return;
    }
    try {
      final responsePemasukan = await http.get(
        Uri.parse('http://10.0.2.2/CatatApp/pemasukan/total.php?user_id=$userId'),
      );
      final responsePengeluaran = await http.get(
        Uri.parse('http://10.0.2.2/CatatApp/pengeluaran/total.php?user_id=$userId'),
      );

      if (responsePemasukan.statusCode == 200 && responsePengeluaran.statusCode == 200) {
        final pemasukanData = jsonDecode(responsePemasukan.body);
        final pengeluaranData = jsonDecode(responsePengeluaran.body);

        setState(() {
          totalPemasukan = double.parse(pemasukanData['total'].toString());
          totalPengeluaran = double.parse(pengeluaranData['total'].toString());
          sisaUang = totalPemasukan - totalPengeluaran;
        });
      } else {

      }
    } catch (e) {
      print('Error fetching financial data: $e');
    }
  }

  List<Map<String, dynamic>> _listPemasukan = [];

  Future<void> fetchDataPemasukan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('https://10.0.2.2/CatatApp/pemasukan/read.php?user_id=$userId&limit=3'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _listPemasukan = List<Map<String, dynamic>>.from(responseData);
      });
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  List<Map<String, dynamic>> _listPengeluaran = [];

  Future<void> fetchDataPengeluaran() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.get(
      Uri.parse('https://10.0.2.2/CatatApp/pengeluaran/read.php?user_id=$userId&limit=3'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _listPengeluaran = List<Map<String, dynamic>>.from(responseData);
      });
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:  true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Catatan Keuangan'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                child: ListTile(
                  title: Text('Sisa Uang'),
                  trailing: Text('Rp ${sisaUang.toStringAsFixed(0)}'),
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Total Pemasukan'),
                      subtitle: Text('Rp ${totalPemasukan.toStringAsFixed(0)}'),
                      onTap: () {
                        Navigator.pushNamed(context, '/pemasukan');
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 26, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (var data in _listPemasukan)
                            Text('${data['judul']}: Rp ${data['jumlah']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Total Pengeluaran'),
                      subtitle: Text('Rp ${totalPengeluaran.toStringAsFixed(0)}'),
                      onTap: () {
                        Navigator.pushNamed(context, '/pengeluaran');
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 26, right: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (var data in _listPengeluaran)
                            Text('${data['judul']}: Rp ${data['jumlah']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
