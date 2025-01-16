import 'package:proyek2/models/laporanPenjualanModel.dart';
import 'package:proyek2/models/detailPesananModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LaporanPenjualanController {
  Future<List<LaporanPenjualan>> fetchLaporanPenjualanByDate(String tanggal) async {
    final response = await http.get(Uri.parse('https://doni.infonering.com/proyek/laporanPenjualan.php?tanggal=$tanggal'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['status'] == 'success' && data['data'] is List) {
        List<LaporanPenjualan> laporanList = (data['data'] as List)
            .map((laporan) => LaporanPenjualan.fromJson(laporan))
            .toList();
        return laporanList;
      } else {
        throw Exception('Failed to load laporan penjualan for date $tanggal');
      }
    } else {
      throw Exception('Failed to load laporan penjualan for date $tanggal');
    }
  }

  Future<List<DetailPesanan>> fetchDetailPesanan(int idPesan) async {
    final response = await http.get(Uri.parse('https://doni.infonering.com/proyek/laporanDetailPenjualan.php?id_pesan=$idPesan'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['status'] == 'success' && data['data'] is List) {
        List<DetailPesanan> laporanDetailList = (data['data'] as List)
            .map((detail) => DetailPesanan.fromJson(detail))
            .toList();
        return laporanDetailList;
      } else {
        throw Exception('Failed to load detail pesanan');
      }
    } else {
      throw Exception('Failed to fetch detail pesanan');
    }
  }
}
