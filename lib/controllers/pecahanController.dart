import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyek2/models/pecahanModel.dart';

class PecahanController {
  final String baseUrl = "https://doni.infonering.com/proyek/pecahan.php";

  // 🔹 Ambil daftar pecahan
  Future<List<Pecahan>> fetchPecahan() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success' && jsonResponse.containsKey('data')) {
          return (jsonResponse['data'] as List)
              .map((pecahan) => Pecahan.fromJson(pecahan))
              .toList();
        } else {
          print("⚠️ API Response Error: ${jsonResponse['message']}");
          return [];
        }
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching pecahan: $e");
      return [];
    }
  }

  // 🔹 Tambahkan pecahan baru
  Future<bool> tambahPecahan(int pecahan, int jumlah) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pecahan": pecahan, "jumlah": jumlah}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        print("✅ Modal berhasil ditambahkan: Pecahan $pecahan, Jumlah $jumlah");
        return true;
      } else {
        print("⚠️ Gagal menambahkan modal: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("⚠️ Exception in tambahPecahan: $e");
      return false;
    }
  }
}
