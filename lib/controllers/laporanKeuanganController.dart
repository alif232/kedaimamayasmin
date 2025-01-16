import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyek2/models/pecahanModel.dart';
import 'package:proyek2/models/laporanKeuanganModel.dart';

class LaporanKeuanganController {
  final String baseUrl = "https://doni.infonering.com/proyek/laporanKeuangan.php"; // Ganti dengan URL API Anda

  Future<List<Pecahan>> fetchPecahan() async {
    final response = await http.get(Uri.parse("$baseUrl?endpoint=pecahan")); // Tambahkan ?endpoint=pecahan
    print("Raw Response Pecahan: ${response.body}"); // Log respons
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body); // Pastikan respons berupa list
      return jsonResponse.map((data) => Pecahan.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load Pecahan");
    }
  }

  Future<List<LaporanKeuangan>> fetchLaporanKeuangan() async {
    final response = await http.get(Uri.parse("$baseUrl?endpoint=laporan_keuangan")); // Tambahkan ?endpoint=laporan_keuangan
    print("Raw Response Laporan: ${response.body}"); // Log respons
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body); // Pastikan respons berupa list
      return jsonResponse.map((data) => LaporanKeuangan.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load Laporan Keuangan");
    }
  }

  Future<int> fetchBalance() async {
    final response = await http.get(Uri.parse("$baseUrl?endpoint=balance")); // Tambahkan ?endpoint=balance
    print("Raw Response: ${response.body}"); // Log respons
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Parsed Balance: ${data['balance']}"); // Log nilai balance
      return data['balance'] ?? 0;
    } else {
      throw Exception("Failed to fetch balance");
    }
  }

  // Add Pengeluaran
  Future<void> addPengeluaran(
    String description,
    List<Pecahan> selectedPecahans,
    List<int> pecahanAmounts,
    int totalAmount) async {
  final uri = Uri.parse("$baseUrl?endpoint=tambah_pengeluaran");
  final requestBody = json.encode({
    'description': description,
    'total_amount': totalAmount, // Sertakan totalAmount
    'pecahans': selectedPecahans
        .asMap()
        .entries
        .map((entry) => {
              'pecahan_id': entry.value.idPecahan,
              'jumlah': pecahanAmounts[entry.key],
            })
        .toList(),
  });

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Pengeluaran added successfully');
    } else {
      print('API error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to add pengeluaran');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to add pengeluaran');
  }
}
}