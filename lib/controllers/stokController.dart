import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyek2/models/stokModel.dart';

class StokController {
  final String baseUrl = 'http://localhost/proyek/stok.php';

  // Fungsi untuk mengambil data stok
  Future<List<Stok>> fetchStok() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Stok.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data stok');
    }
  }

  // Fungsi untuk menambahkan stok
  Future<void> addStok(int idMenu, int jumlahStok) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "id_menu": idMenu.toString(),
        "jumlah_stok": jumlahStok.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan stok');
    }
  }
}
