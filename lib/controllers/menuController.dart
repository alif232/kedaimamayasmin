import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:proyek2/models/menuModel.dart';

class MenuController {
  static const String baseUrl = 'https://doni.infonering.com/proyek/menu.php';

  // Fetch all menus
  Future<List<Menu>> fetchMenus() async {
  final response = await http.get(Uri.parse(baseUrl));
  print("Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");
 
  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    if (decoded['status'] == 'success') {
      return (decoded['data'] as List)
          .map((item) => Menu.fromJson(item))
          .toList();
    } else {
      throw Exception(decoded['message'] ?? 'Unknown error');
    }
  } else {
    throw Exception('HTTP Error: ${response.statusCode}');
  }
}

  // Add new menu with image
  Future<void> addMenuWithImageWeb(Menu menu, Uint8List imageBytes, String fileName) async {
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    
    // Menambahkan data form lainnya
    request.fields.addAll({
      'nama': menu.nama,
      'kategori': menu.kategori,
      'harga': menu.harga.toString(),
      'stok': menu.stok.toString(),
    });

    // Menambahkan gambar sebagai file
    request.files.add(http.MultipartFile.fromBytes('gambar', imageBytes, filename: fileName));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to add menu');
    }
  }

  // Update menu 
  Future<void> updateMenu(Menu menu, {Uint8List? imageBytes, String? fileName}) async {
  final request = http.MultipartRequest('POST', Uri.parse('https://doni.infonering.com/proyek/updateMenu.php'));

  // Tambahkan data menu ke form
  request.fields.addAll({
    'id_menu': menu.idMenu.toString(),
    'nama': menu.nama,
    'kategori': menu.kategori,
    'harga': menu.harga.toString(),
    'stok': menu.stok.toString(),
    'gambar': menu.gambar ?? '', // Gambar lama jika tidak diubah
  });

  // Tambahkan gambar baru jika ada
  if (imageBytes != null && fileName != null) {
    request.files.add(http.MultipartFile.fromBytes('gambar', imageBytes, filename: fileName));
  }

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  if (response.statusCode != 200) {
    throw Exception('Gagal memperbarui menu: $responseBody');
  }
}


    // Delete a menu
    Future<void> deleteMenu(int id) async {
    final response = await http.delete(Uri.parse('https://doni.infonering.com/proyek/deleteMenu.php?id=$id')); // Tambahkan ID sebagai query string
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus menu');
    }
  }
}