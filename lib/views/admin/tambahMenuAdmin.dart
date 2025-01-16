import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
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

  String? _kategori;
  File? _selectedImage;

  final CustomMenuController.MenuController _menuController =
      CustomMenuController.MenuController();

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada gambar dipilih')),
      );
    }
  }

  Uint8List? _getImageBytes() {
    return _selectedImage?.readAsBytesSync();
  }

  void _simpanMenu() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final newMenu = Menu(
        idMenu: 0,
        nama: _namaController.text,
        kategori: _kategori!,
        harga: int.parse(_hargaController.text),
        stok: 0,
        gambar: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        Uint8List? imageBytes = _getImageBytes();
        if (imageBytes != null) {
          await _menuController.addMenuWithImageWeb(newMenu, imageBytes, _selectedImage!.path.split('/').last);
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan menu: $e')),
        );
      }
    } else {
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
        color: Colors.purple[800],
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
                            : Image.file(
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
