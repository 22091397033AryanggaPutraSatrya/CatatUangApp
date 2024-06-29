import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PemasukanScreen extends StatefulWidget {
  @override
  _PemasukanScreenState createState() => _PemasukanScreenState();
}

class _PemasukanScreenState extends State<PemasukanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _judul = '';
  double _jumlah = 0.0;
  String _deskripsi = '';

  List<Map<String, dynamic>> _listPemasukan = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2/CatatApp/pemasukan/read.php?user_id=$userId'),
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

  Future<void> _tambahPemasukan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2/CatatApp/pemasukan/create.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'judul': _judul,
        'jumlah': _jumlah,
        'deskripsi': _deskripsi,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      fetchData();
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  Future<void> _hapusPemasukan(int idPemasukan) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2/CatatApp/pemasukan/delete.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'id': idPemasukan,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pemasukan berhasil dihapus')),
      );
      fetchData(); // Mengambil ulang data setelah penghapusan
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  Future<void> _editPemasukan(int idPemasukan, String judul, double jumlah, String deskripsi) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2/CatatApp/pemasukan/update.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'id': idPemasukan,
        'judul': judul,
        'jumlah': jumlah,
        'deskripsi': deskripsi,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pemasukan berhasil diperbarui')),
      );
      fetchData(); // Mengambil ulang data setelah penghapusan
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemasukan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Judul'),
                    onSaved: (value) {
                      _judul = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Jumlah'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _jumlah = double.parse(value!);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Deskripsi'),
                    onSaved: (value) {
                      _deskripsi = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState?.save();
                      _tambahPemasukan();
                    },
                    child: Text('Tambah Pemasukan'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _listPemasukan.length,
                itemBuilder: (BuildContext context, int index) {
                  final pemasukan = _listPemasukan[index];
                  final double jumlahPemasukan = double.parse(pemasukan['jumlah']);
                  return ListTile(
                    title: Text('${pemasukan['judul']} (${pemasukan['deskripsi']})'),
                    subtitle: Text('Rp ${jumlahPemasukan.toStringAsFixed(0)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Edit Pemasukan'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          initialValue: pemasukan['judul'],
                                          decoration: InputDecoration(labelText: 'Judul'),
                                          onChanged: (value) {
                                            _judul = value;
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: pemasukan['jumlah'].toString(),
                                          decoration: InputDecoration(labelText: 'Jumlah'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            _jumlah = double.parse(value);
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: pemasukan['deskripsi'],
                                          decoration: InputDecoration(labelText: 'Deskripsi'),
                                          onChanged: (value) {
                                            _deskripsi = value;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _editPemasukan(
                                          pemasukan['id'],
                                          _judul.isEmpty ? pemasukan['judul'] : _judul,
                                          _jumlah == 0.0 ? double.parse(pemasukan['jumlah']) : _jumlah,
                                          _deskripsi.isEmpty ? pemasukan['deskripsi'] : _deskripsi,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Simpan'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text('Apakah Anda yakin ingin menghapus pemasukan ini?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Panggil fungsi untuk menghapus data pemasukan di sini
                                        _hapusPemasukan(pemasukan['id']);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
