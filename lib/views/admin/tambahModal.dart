import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 📌 Import untuk format uang
import 'package:proyek2/controllers/pecahanController.dart';

class TambahModalPage extends StatefulWidget {
  @override
  _TambahModalPageState createState() => _TambahModalPageState();
}

class _TambahModalPageState extends State<TambahModalPage> {
  final List<int> pecahanList = [100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];
  int? selectedPecahan;
  final TextEditingController jumlahController = TextEditingController();
  final PecahanController _controller = PecahanController();

  // 📌 Fungsi untuk format uang ke Rupiah
  String formatRupiah(int value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  void _simpanModal() async {
    if (selectedPecahan == null || jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap pilih pecahan dan isi jumlah")),
      );
      return;
    }

    try {
      int jumlah = int.parse(jumlahController.text);
      bool success = await _controller.tambahPecahan(selectedPecahan!, jumlah);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Modal berhasil ditambahkan!")),
        );
        Navigator.pop(context, true); // Kembali dan refresh halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan modal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        title: Text('Tambah Modal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Dropdown Pilihan Pecahan
            Text("Pilih Pecahan", style: _labelStyle()),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedPecahan,
              decoration: _formDecoration(),
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.black, fontSize: 16),
              items: pecahanList.map((pecahan) {
                return DropdownMenuItem(
                  value: pecahan,
                  child: Text(formatRupiah(pecahan)), // 📌 Format pecahan ke Rupiah
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPecahan = value;
                });
              },
            ),
            SizedBox(height: 20),

            // 🔹 Input Jumlah
            Text("Jumlah Pecahan", style: _labelStyle()),
            SizedBox(height: 8),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: _formDecoration().copyWith(hintText: "Masukkan jumlah pecahan"),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 30),

            // 🔹 Tombol Simpan
            Center(
              child: ElevatedButton.icon(
                onPressed: _simpanModal,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text("Simpan Modal", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Styling label teks
  TextStyle _labelStyle() {
    return TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600);
  }

  // 📌 Styling form input
  InputDecoration _formDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white, // 📌 Form berwarna putih
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}
