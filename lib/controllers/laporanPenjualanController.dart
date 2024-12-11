import 'package:proyek2/models/laporanPenjualanModel.dart';
import 'package:proyek2/models/detailPesananModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanPenjualanController {
  Future<List<LaporanPenjualan>> fetchLaporanPenjualan() async {
    final response = await http.get(Uri.parse('http://localhost/proyek/laporanPenjualan.php'));

    if (response.statusCode == 200) {
      // Decode the response
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Check if the response contains 'data' and it's an array
      if (data['status'] == 'success' && data['data'] is List) {
        // Convert the 'data' part of the JSON to a List of LaporanPenjualan
        List<LaporanPenjualan> laporanList = (data['data'] as List)
            .map((laporan) => LaporanPenjualan.fromJson(laporan))
            .toList();

        return laporanList;
      } else {
        // Handle error: no data or incorrect response structure
        throw Exception('Failed to load laporan penjualan');
      }
    } else {
      throw Exception('Failed to load laporan penjualan');
    }
  }


  Future<List<DetailPesanan>> fetchDetailPesanan(int idPesan) async {
    final response = await http.get(Uri.parse('http://localhost/proyek/laporanDetailPenjualan.php?id_pesan=$idPesan'));

    if (response.statusCode == 200) {
      // Decode the JSON response into a Map
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Check if the response contains 'data' and it's a List
      if (data['status'] == 'success' && data['data'] is List) {
        // Map the 'data' to a List of LaporanDetail
        List<DetailPesanan> laporanDetailList = (data['data'] as List)
            .map((detail) => DetailPesanan.fromJson(detail))
            .toList();

        return laporanDetailList;
      } else {
        // Handle error: no data or incorrect response structure
        throw Exception('Failed to load detail pesanan');
      }
    } else {
      throw Exception('Failed to fetch detail pesanan');
    }
  }
}
