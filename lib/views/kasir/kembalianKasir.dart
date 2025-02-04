import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/models/pecahanModel.dart';
import 'package:proyek2/controllers/pecahanController.dart';
import 'package:proyek2/controllers/pesananController.dart';
import 'package:proyek2/views/kasir/struk.dart';

class KembalianKasir extends StatefulWidget {
  final double kembalian;
  final String namaPemesan;
  final List<Map<String, dynamic>> daftarProduk;
  final double totalHarga;
  final double uangDiberikan;

  const KembalianKasir({
    Key? key,
    required this.kembalian,
    required this.namaPemesan,
    required this.daftarProduk,
    required this.totalHarga,
    required this.uangDiberikan,
  }) : super(key: key);

  @override
  _KembalianKasirState createState() => _KembalianKasirState();
}

class _KembalianKasirState extends State<KembalianKasir> {
  late Future<List<Pecahan>> futurePecahanList;
  String? errorMessage;
  final PesananController pesananController = PesananController();

  final Map<int, String> pecahanImages = {
    100000: 'assets/100k.png',
    50000: 'assets/50k.png',
    20000: 'assets/20k.png',
    10000: 'assets/10k.png',
    5000: 'assets/5k.png',
    2000: 'assets/2k.png',
    1000: 'assets/1k.png',
    500: 'assets/500p.png',
    200: 'assets/200p.jpg', // Tambahan gambar pecahan 200
    100: 'assets/100p.jpg', // Tambahan gambar pecahan 100
  };

  @override
  void initState() {
    super.initState();
    futurePecahanList = PecahanController().fetchPecahan();
  }

  Future<Map<int, int>> _hitungKembalian(double kembalian, List<Pecahan> pecahanList) async {
    Map<int, int> hasilKembalian = {};

    pecahanList.sort((a, b) => b.pecahan.compareTo(a.pecahan)); // Urutkan pecahan dari terbesar ke terkecil

    for (var pecahan in pecahanList) {
      int jumlahPecahan = (kembalian ~/ pecahan.pecahan).toInt();
      if (jumlahPecahan > 0 && pecahan.jumlah > 0) {
        int yangDiberikan = jumlahPecahan <= pecahan.jumlah ? jumlahPecahan : pecahan.jumlah;
        hasilKembalian[pecahan.pecahan] = yangDiberikan;
        kembalian -= yangDiberikan * pecahan.pecahan;
      }

      if (kembalian == 0) break;
    }

    return hasilKembalian;
  }

  Future<void> _selesaikanPesanan() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StrukPembelian(
          tanggalPesan: DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
          namaPemesan: widget.namaPemesan,
          daftarProduk: widget.daftarProduk,
          totalHarga: widget.totalHarga,
          uangDiberikan: widget.uangDiberikan,
          uangKembali: widget.kembalian,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kembalian Kasir'),
        backgroundColor: Colors.purple[900],
      ),
      backgroundColor: Colors.purple[900],
      body: widget.kembalian == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tidak ada kembalian yang harus diberikan.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selesaikanPesanan,
                    child: Text('Pesanan Selesai', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<Pecahan>>(
              future: futurePecahanList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal mengambil data pecahan: ${snapshot.error}',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                } else if (snapshot.hasData) {
                  List<Pecahan> pecahanList = snapshot.data!;
                  return FutureBuilder<Map<int, int>>(
                    future: _hitungKembalian(widget.kembalian, pecahanList),
                    builder: (context, kembalianSnapshot) {
                      if (kembalianSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (kembalianSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Gagal menghitung kembalian: ${kembalianSnapshot.error}',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        );
                      } else if (kembalianSnapshot.hasData) {
                        Map<int, int> hasilKembalian = kembalianSnapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Kembalian: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(widget.kembalian)}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: hasilKembalian.length,
                                  itemBuilder: (context, index) {
                                    int pecahan = hasilKembalian.keys.elementAt(index);
                                    int jumlah = hasilKembalian[pecahan]!;
                                    final imagePath = pecahanImages[pecahan] ?? 'assets/default.png';
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 12.0),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.asset(
                                                imagePath,
                                                width: 100,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Pecahan: Rp ${NumberFormat("#,##0", "id_ID").format(pecahan)},00',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Text(
                                              '${jumlah}x',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _selesaikanPesanan,
                                  child: Text('Pesanan Selesai', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: Text('Tidak ada data kembalian.'));
                      }
                    },
                  );
                } else {
                  return Center(child: Text('Tidak ada data pecahan.'));
                }
              },
            ),
    );
  }
}
