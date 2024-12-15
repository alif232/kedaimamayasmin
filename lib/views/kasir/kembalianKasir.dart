import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/models/pecahanModel.dart';
import 'package:proyek2/controllers/pecahanController.dart';
import 'package:proyek2/controllers/pesananController.dart';
import 'package:proyek2/views/kasir/dashboardKasir.dart';  // Import dashboardKasir.dart

class KembalianKasir extends StatefulWidget {
  final double kembalian;

  const KembalianKasir({
    Key? key,
    required this.kembalian,
  }) : super(key: key);

  @override
  _KembalianKasirState createState() => _KembalianKasirState();
}

class _KembalianKasirState extends State<KembalianKasir> {
  late Future<List<Pecahan>> futurePecahanList;
  List<Pecahan> kembalianList = [];
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
  };

  @override
  void initState() {
    super.initState();
    futurePecahanList = PecahanController().fetchPecahan(); // Use the controller instance here
  }

  List<Pecahan> _hitungKembalian(double kembalian, List<Pecahan> pecahanList) {
    List<Pecahan> hasil = [];
    double sisa = kembalian;

    for (var pecahan in pecahanList) {
      int jumlah = (sisa ~/ pecahan.pecahan).toInt();
      if (jumlah > 0) {
        int jumlahTersedia = pecahan.jumlah;
        int jumlahYangDigunakan = jumlah > jumlahTersedia ? jumlahTersedia : jumlah;

        if (jumlahYangDigunakan > 0) {
          hasil.add(Pecahan(
            idPecahan: pecahan.idPecahan,
            pecahan: pecahan.pecahan,
            jumlah: jumlahYangDigunakan,
          ));
        }

        sisa -= jumlahYangDigunakan * pecahan.pecahan;
        if (sisa <= 0) break;
      }
    }

    if (sisa > 0) {
      errorMessage = 'Tidak ada uang pecahan yang mencukupi untuk kembalian.';
    }

    return hasil;
  }

  Future<void> _selesaikanPesanan() async {
    if (kembalianList.isNotEmpty) {
      bool berhasil = await pesananController.kembalian(pecahanList: kembalianList); // Call kembalian() function
      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesanan selesai dan pecahan diperbarui.')),
        );
        // Navigate back to dashboardKasir and refresh it
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardKasir()),  // Navigate to DashboardKasir
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui pecahan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kembalian == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Kembalian Kasir'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tidak ada kembalian yang harus diberikan.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selesaikanPesanan,
                child: Text('Pesanan Selesai'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kembalian Kasir'),
      ),
      backgroundColor: Colors.purple[900], // Set background to purple 900
      body: FutureBuilder<List<Pecahan>>(
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
            kembalianList = _hitungKembalian(widget.kembalian, pecahanList);

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
                  kembalianList.isEmpty
                      ? Center(
                          child: Text(
                            errorMessage ?? 'Tidak ada uang pecahan untuk memberikan kembalian.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Expanded(
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: kembalianList.length,
                            itemBuilder: (context, index) {
                              final pecahan = kembalianList[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      pecahanImages[pecahan.pecahan] ?? '',
                                      width: 400,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text('${pecahan.jumlah}x', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 16),
                  Divider(color: Colors.white),
                  SizedBox(height: 16),
                 Center(
                    child: ElevatedButton(
                      onPressed: _selesaikanPesanan,
                      child: Text('Pesanan Selesai', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Use backgroundColor instead of primary
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Tidak ada data pecahan.'));
          }
        },
      ),
    );
  }
}
