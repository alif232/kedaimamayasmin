import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proyek2/controllers/menuController.dart' as CustomMenuController;
import 'package:proyek2/models/menuModel.dart';

class TambahMenu extends StatefulWidget {
  @override
  _TambahMenuState createState() => _TambahMenuState();
}

class _TambahMenuState extends State<TambahMenu> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  String? _kategori; // Untuk form select kategori
  Uint8List? _selectedImage; // Untuk menyimpan data gambar
  String? _fileName; // Nama file untuk identifikasi

  final CustomMenuController.MenuController _menuController =
      CustomMenuController.MenuController();

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Hanya mendukung file gambar
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImage = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  void _simpanMenu() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final newMenu = Menu(
        idMenu: 0, // ID akan di-generate oleh server
        nama: _namaController.text,
        kategori: _kategori!,
        harga: int.parse(_hargaController.text),
        stok: 0, // Tidak digunakan karena form stok dihapus
        gambar: null, // Gambar dikelola terpisah
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await _menuController.addMenuWithImageWeb(newMenu, _selectedImage!, _fileName!);
        Navigator.pop(context, true); // Berhasil simpan
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan menu: $e')),
        );
      }
    } else if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Menu')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.purple[800], // Background warna purple
        child: Center(
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Menu',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Menu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama menu harus diisi' : null,
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _kategori,
                      items: ['Makanan', 'Minuman']
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _kategori = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: (value) =>
                          value == null ? 'Pilih kategori terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _hargaController,
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        prefixText: 'Rp. ',
                        suffixText: '.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Harga harus diisi' : null,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        _selectedImage == null
                            ? Text('Tidak ada gambar dipilih',
                                style: TextStyle(color: Colors.grey[600]))
                            : Image.memory(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                          ),
                          child: Text('Pilih Gambar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _simpanMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

