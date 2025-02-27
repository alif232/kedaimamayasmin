import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyek2/models/laporanPenjualanModel.dart';
import 'package:proyek2/models/detailPesananModel.dart';

class LaporanPenjualanController {
  final String baseUrl = "https://doni.infonering.com/proyek";

  // 🔹 Ambil daftar laporan penjualan berdasarkan tanggal
  Future<List<LaporanPenjualan>> fetchLaporanPenjualanByDate(String tanggal) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/laporanPenjualan.php?tanggal=$tanggal"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data_harian'] is List) {
          return (data['data_harian'] as List)
              .map((laporan) => LaporanPenjualan.fromJson(laporan))
              .toList();
        } else {
          print("⚠️ API Response Error: ${data['message']}");
          return [];
        }
      } else {
        print("⚠️ Server Error (${response.statusCode}): ${response.body}");
        throw Exception("Failed to load laporan penjualan for date $tanggal");
      }
    } catch (e) {
      print("⚠️ Exception in fetchLaporanPenjualanByDate: $e");
      return [];
    }
  }

  // 🔹 Ambil detail pesanan berdasarkan ID pesanan
  Future<List<DetailPesanan>> fetchDetailPesanan(int idPesan) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/laporanDetailPenjualan.php?id_pesan=$idPesan"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] is List) {
          return (data['data'] as List)
              .map((detail) => DetailPesanan.fromJson(detail))
              .toList();
        } else {
          print("⚠️ API Response Error: ${data['message']}");
          return [];
        }
      } else {
        print("⚠️ Server Error (${response.statusCode}): ${response.body}");
        throw Exception("Failed to fetch detail pesanan");
      }
    } catch (e) {
      print("⚠️ Exception in fetchDetailPesanan: $e");
      return [];
    }
  }

  // 🔹 Ambil total penjualan berdasarkan tanggal tertentu
  Future<int> fetchTotalPenjualanByDate(String tanggal) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/laporanPenjualan.php?tanggal=$tanggal"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success' && data.containsKey('total_penjualan_harian')) {
          return int.tryParse(data['total_penjualan_harian'].toString()) ?? 0;
        } else {
          print("⚠️ API Response Error: ${data['message']}");
          return 0;
        }
      } else {
        print("⚠️ Server Error (${response.statusCode}): ${response.body}");
        throw Exception("Failed to load total penjualan for date $tanggal");
      }
    } catch (e) {
      print("⚠️ Exception in fetchTotalPenjualanByDate: $e");
      return 0;
    }
  }

  // 🔹 Ambil total penjualan mingguan berdasarkan bulan, tahun, dan minggu tertentu
  Future<Map<String, int>> fetchPenjualanMingguan(int bulan, int tahun, int minggu) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/laporanPenjualan.php?bulan=$bulan&tahun=$tahun&minggu=$minggu"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success' && data.containsKey('data_mingguan')) {
          Map<String, int> result = {};
          (data['data_mingguan'] as Map<String, dynamic>).forEach((key, value) {
            result[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
          });
          return result;
        } else {
          print("⚠️ API Response Error: ${data['message']}");
          return {};
        }
      } else {
        print("⚠️ Server Error (${response.statusCode}): ${response.body}");
        throw Exception("Failed to load laporan mingguan");
      }
    } catch (e) {
      print("⚠️ Exception in fetchPenjualanMingguan: $e");
      return {};
    }
  }

  Future<int> fetchTotalPesananByDate(String tanggal) async {
    final response = await http.get(Uri.parse("https://doni.infonering.com/proyek/laporanPenjualan.php?tanggal=$tanggal"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'success' && data.containsKey('total_pesanan')) {
        return int.tryParse(data['total_pesanan'].toString()) ?? 0;
      } else {
        print("⚠️ API Response Error: ${data['message']}");
        return 0;
      }
    } else {
      print("⚠️ Server Error (${response.statusCode}): ${response.body}");
      throw Exception("Failed to load total pesanan for date $tanggal");
    }
  }

}
