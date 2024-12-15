import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/models/menuModel.dart';
import 'package:proyek2/controllers/pesananController.dart'; // Import PesananController
import 'package:proyek2/views/kasir/bayarKasir.dart';

class DetailPesananKasir extends StatefulWidget {
  final List<Menu> keranjang;
  final double totalHarga;

  const DetailPesananKasir({
    Key? key,
    required this.keranjang,
    required this.totalHarga,
  }) : super(key: key);

  @override
  _DetailPesananKasirState createState() => _DetailPesananKasirState();
}

class _DetailPesananKasirState extends State<DetailPesananKasir> {
  final TextEditingController _namaController = TextEditingController();
  final PesananController _pesananController = PesananController(); // Instance PesananController

  Future<void> _prosesPesanan() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama pembeli harus diisi!')),
      );
      return;
    }

    List<Map<String, dynamic>> keranjangData = widget.keranjang.map((menu) {
      return {
        'id_menu': menu.idMenu,
        'jumlah': menu.jumlahPesanan,
        'harga': menu.harga,
        'total_harga': menu.harga * menu.jumlahPesanan,
      };
    }).toList();

    try {
      // Kirim pesanan ke server
      bool berhasil = await _pesananController.kirimPesanan(
        nama: _namaController.text,
        keranjang: keranjangData,
        totalHarga: widget.totalHarga,
      );

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesanan berhasil disimpan.')),
        );

        // Navigasi ke halaman BayarKasir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BayarKasir(
              keranjang: widget.keranjang,
              totalHarga: widget.totalHarga,
              nama: _namaController.text, // Kirim nama pembeli ke BayarKasir
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses pesanan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900], // Set the background color to purple
      appBar: AppBar(
        title: Text('Detail Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Pesanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            
            // The form for Nama Pembeli inside a Card
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Pembeli',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama pembeli',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // List of items (keranjang) placed above the cards
            Expanded(
              child: ListView.builder(
                itemCount: widget.keranjang.length,
                itemBuilder: (context, index) {
                  final menu = widget.keranjang[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(menu.nama),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(menu.harga)}',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text('Jumlah: ${menu.jumlahPesanan}', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      trailing: Text(
                        '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(menu.harga * menu.jumlahPesanan)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 2, color: Colors.white),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(widget.totalHarga)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _prosesPesanan, // Proses pesanan dan navigasi ke BayarKasir
                  child: Text('Bayar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set the background color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
