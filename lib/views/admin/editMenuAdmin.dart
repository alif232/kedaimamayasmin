import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyek2/controllers/menuController.dart' as CustomMenuController;
import 'package:proyek2/models/menuModel.dart';

class EditMenu extends StatefulWidget {
  final Menu menu;

  const EditMenu({Key? key, required this.menu}) : super(key: key);

  @override
  _EditMenuState createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;

  File? _selectedImage;
  String? _selectedCategory;
  final CustomMenuController.MenuController _menuController =
      CustomMenuController.MenuController();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.menu.nama);
    _hargaController = TextEditingController(text: widget.menu.harga.toString());
    _selectedCategory = widget.menu.kategori;
  }

  // Fungsi untuk memilih gambar menggunakan image_picker
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

  void _updateMenu() async {
    if (_formKey.currentState!.validate()) {
      final updatedMenu = Menu(
        idMenu: widget.menu.idMenu,
        nama: _namaController.text,
        kategori: _selectedCategory!,
        harga: int.parse(_hargaController.text),
        stok: widget.menu.stok,
        gambar: widget.menu.gambar,
        createdAt: widget.menu.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        Uint8List? imageBytes = _getImageBytes();
        await _menuController.updateMenu(
          updatedMenu,
          imageBytes: imageBytes,
          fileName: _selectedImage != null
              ? _selectedImage!.path.split('/').last
              : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui menu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu'),
      ),
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
                      'Edit Menu',
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
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: <String>['Makanan', 'Minuman']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: (value) =>
                          value == null ? 'Kategori harus dipilih' : null,
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
                        _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : widget.menu.gambar != null && widget.menu.gambar!.isNotEmpty
                                ? FadeInImage.assetNetwork(
                                    placeholder: 'assets/logo.png',
                                    image: 'https://alif.infonering.com/proyek/${widget.menu.gambar!}',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/default_image.png',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Text('Tidak ada gambar'),
                        Spacer(),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Pilih Gambar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateMenu,
                        child: Text('Update'),
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
