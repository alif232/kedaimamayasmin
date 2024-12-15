import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyek2/models/pecahanModel.dart';

class PesananController {
  static const String _urlPesan = 'http://localhost/proyek/prosesPesan.php';
  static const String _urlUpdatePecahan = 'http://localhost/proyek/updatePecahan.php';
  static const String _urlKembalian = 'http://localhost/proyek/kembalian.php';

  Future<bool> kirimPesanan({
    required String nama,
    required List<Map<String, dynamic>> keranjang,
    required double totalHarga,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_urlPesan),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'keranjang': keranjang,
          'total_harga': totalHarga,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != null) {
          return true;
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Gagal mengirim pesanan, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengirim pesanan: $e');
    }
  }

  // Fungsi untuk menyimpan pecahan ke database
    Future<bool> simpanPecahan({
      required String namaPembeli,
      required List<Map<String, dynamic>> pecahanList,
    }) async {
      try {
        final response = await http.post(
          Uri.parse(_urlUpdatePecahan),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nama_pembeli': namaPembeli,
            'pecahan': pecahanList,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['success'] == true;
        } else {
          throw Exception('Gagal menyimpan pecahan, status code: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Gagal menyimpan pecahan: $e');
      }
    }

    // Fungsi untuk menyimpan data kembalian
    Future<bool> kembalian({required List<Pecahan> pecahanList}) async {
    try {
      // Convert List<Pecahan> to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> pecahanData = pecahanList.map((pecahan) {
        return {
          'pecahan': pecahan.pecahan,
          'jumlah': -pecahan.jumlah, // Ensure the amount is negative (decrease quantity)
        };
      }).toList();

      // Send the updated pecahan data to the API
      final response = await http.post(
        Uri.parse(_urlKembalian),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pecahan': pecahanData}),
      );

      if (response.statusCode == 200) {
        return true;  // Success
      } else {
        throw Exception('Failed to update pecahan');
      }
    } catch (e) {
      print('Error updating pecahan: $e');
      return false;
    }
  }
}