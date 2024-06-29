import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PengeluaranScreen extends StatefulWidget {
  @override
  _PengeluaranScreenState createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  final _formKey = GlobalKey<FormState>();
  String _judul = '';
  double _jumlah = 0.0;
  String _deskripsi = '';

  List<Map<String, dynamic>> _listPengeluaran = [];

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
      Uri.parse('http://10.0.2.2/CatatApp/pengeluaran/read.php?user_id=$userId'),
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

  Future<void> _tambahPengeluaran() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2/CatatApp/pengeluaran/create.php'),
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
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  Future<void> _editPengeluaran(int idPengeluaran, String judul, double jumlah, String deskripsi) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2/CatatApp/pengeluaran/update.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'id': idPengeluaran,
        'judul': judul,
        'jumlah': jumlah,
        'deskripsi': deskripsi,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengeluaran berhasil diperbarui')),
      );
      fetchData(); // Mengambil ulang data setelah pembaruan
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    }
  }

  Future<void> _hapusPengeluaran(int idPengeluaran) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    if (userId == null) {

      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2/CatatApp/pengeluaran/delete.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'id': idPengeluaran,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengeluaran berhasil dihapus')),
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
        title: Text('Pengeluaran'),
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
                      _tambahPengeluaran();
                    },
                    child: Text('Tambah Pengeluaran'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _listPengeluaran.length,
                itemBuilder: (BuildContext context, int index) {
                  final pengeluaran = _listPengeluaran[index];
                  final double jumlahPengeluaran = double.parse(pengeluaran['jumlah']);
                  return ListTile(
                    title: Text('${pengeluaran['judul']} (${pengeluaran['deskripsi']})'),
                    subtitle: Text('Rp ${jumlahPengeluaran.toStringAsFixed(0)}'),
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
                                  title: Text('Edit Pengeluaran'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          initialValue: pengeluaran['judul'], // Atur nilai awal dengan nilai judul yang sudah ada
                                          decoration: InputDecoration(labelText: 'Judul'),
                                          onChanged: (value) {
                                            _judul = value; // Simpan nilai judul yang baru diubah
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: pengeluaran['jumlah'].toString(), // Atur nilai awal dengan nilai jumlah yang sudah ada
                                          decoration: InputDecoration(labelText: 'Jumlah'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            _jumlah = double.parse(value); // Simpan nilai jumlah yang baru diubah
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: pengeluaran['deskripsi'], // Atur nilai awal dengan nilai deskripsi yang sudah ada
                                          decoration: InputDecoration(labelText: 'Deskripsi'),
                                          onChanged: (value) {
                                            _deskripsi = value; // Simpan nilai deskripsi yang baru diubah
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
                                        _editPengeluaran(
                                          pengeluaran['id'],
                                          _judul.isEmpty ? pengeluaran['judul'] : _judul, // Jika _judul kosong, gunakan nilai sebelumnya
                                          _jumlah == 0.0 ? double.parse(pengeluaran['jumlah']) : _jumlah, // Jika _jumlah = 0, gunakan nilai sebelumnya
                                          _deskripsi.isEmpty ? pengeluaran['deskripsi'] : _deskripsi, // Jika _deskripsi kosong, gunakan nilai sebelumnya
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
                                  content: Text('Apakah Anda yakin ingin menghapus pengeluaran ini?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Panggil fungsi untuk menghapus data pengeluaran di sini
                                        _hapusPengeluaran(pengeluaran['id']);
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
