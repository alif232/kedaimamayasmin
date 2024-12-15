import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/menuController.dart' as CustomMenuController;
import 'package:proyek2/models/menuModel.dart';
import 'package:proyek2/views/admin/tambahMenuAdmin.dart';
import 'package:proyek2/views/admin/editMenuAdmin.dart';

class KelolaMenuAdmin extends StatefulWidget {
  const KelolaMenuAdmin({Key? key}) : super(key: key);

  @override
  _KelolaMenuAdminState createState() => _KelolaMenuAdminState();
}

class _KelolaMenuAdminState extends State<KelolaMenuAdmin> {
  final CustomMenuController.MenuController _menuController =
      CustomMenuController.MenuController();

  List<Menu> _menus = [];
  List<Menu> _filteredMenus = []; // Menyimpan hasil filter menu
  bool _isLoading = true;
  String _searchQuery = ''; // Menyimpan query pencarian

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  // Fungsi untuk memuat daftar menu dari server
  void fetchMenus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final menus = await _menuController.fetchMenus();
      setState(() {
        _menus = menus;
        _applyFilter(); // Terapkan filter setelah data diambil
        _isLoading = false;
      });
    } catch (e) {
      print('Error while fetching menus: $e');
      setState(() {
        _menus = [];
        _filteredMenus = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data menu: $e')),
      );
    }
  }

  // Fungsi untuk memfilter data berdasarkan teks pencarian
  void _applyFilter() {
    setState(() {
      _filteredMenus = _menus
          .where((menu) =>
              menu.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              menu.kategori.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<Uint8List?> fetchImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes; // Mengembalikan byte array gambar
      }
    } catch (e) {
      print('Gagal mengunduh gambar: $e');
    }
    return null; // Jika gagal, kembalikan null
  }

  void _navigateToTambahMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahMenu()),
    );
    if (result == true) {
      fetchMenus();
    }
  }

  void _navigateToEditMenu(Menu menu) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMenu(menu: menu)),
    );
    if (result == true) {
      fetchMenus();
    }
  }

  // Fungsi untuk menampilkan konfirmasi sebelum menghapus menu
  void _showDeleteConfirmationDialog(Menu menu) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus menu ${menu.nama}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                deleteMenu(menu.idMenu); // Panggil fungsi deleteMenu
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus menu
  void deleteMenu(int id) async {
    try {
      await _menuController.deleteMenu(id);
      fetchMenus(); // Memuat ulang daftar menu setelah penghapusan berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus menu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Menu'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.purple[900]), // Background gelap
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget Pencarian
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari menu...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Update query pencarian
                    _applyFilter(); // Terapkan filter
                  });
                },
              ),
            ),
            // Tombol Tambah Data
            ElevatedButton(
              onPressed: _navigateToTambahMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Warna tombol
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              child: Text('Tambah Data', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16.0), // Spasi antara tombol dan tabel
            // Tabel
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredMenus.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada menu ditemukan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : DataTable2(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.purple[400]),
                          columnSpacing: 16.0,
                          minWidth: 800,
                          columns: [
                            DataColumn(
                              label:
                                  Text('No', style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label:
                                  Text('Nama', style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Kategori',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Harga',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Gambar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          rows: _filteredMenus.asMap().map((index, menu) {
                            return MapEntry(
                                index,
                                DataRow(
                                  color: MaterialStateProperty.all(Colors.purple[800]),
                                  cells: [
                                    DataCell(
                                      Text(
                                        (index + 1).toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              menu.nama,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _navigateToEditMenu(menu);
                                              } else if (value == 'delete') {
                                                _showDeleteConfirmationDialog(menu); // Menampilkan konfirmasi hapus
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        menu.kategori,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 2,
                                        ).format(menu.harga),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    DataCell(
                                      FutureBuilder<Uint8List?>(
                                        future: fetchImage(
                                            'http://localhost/proyek/${menu.gambar}'),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }
                                          if (snapshot.hasError ||
                                              snapshot.data == null) {
                                            return Text('Tidak ada gambar',
                                                style: TextStyle(color: Colors.white));
                                          }
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ));
                          }).values.toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
