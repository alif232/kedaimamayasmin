import 'package:flutter/material.dart';
import 'package:proyek2/controllers/pecahanController.dart';
import 'package:proyek2/models/pecahanModel.dart';
import 'package:intl/intl.dart'; // 📌 Import untuk format rupiah
import 'package:proyek2/views/admin/tambahModal.dart';

class ModalPenjualanAdmin extends StatefulWidget {
  @override
  _ModalPenjualanAdminState createState() => _ModalPenjualanAdminState();
}

class _ModalPenjualanAdminState extends State<ModalPenjualanAdmin> {
  final PecahanController _controller = PecahanController();
  List<Pecahan> _pecahanList = [];

  @override
  void initState() {
    super.initState();
    _fetchPecahan();
  }

  void _fetchPecahan() async {
    try {
      List<Pecahan> pecahanList = await _controller.fetchPecahan();
      setState(() {
        _pecahanList = pecahanList;
      });
    } catch (e) {
      print("⚠️ Error fetching pecahan: $e");
    }
  }

  // 📌 Fungsi untuk format rupiah
  String formatRupiah(int value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        title: Text('Modal Penjualan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Tombol Tambah Modal
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TambahModalPage()),
                  ).then((_) => _fetchPecahan());
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Tambah Modal", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // 🔹 Tabel Pecahan Modal dengan Scroll
            Expanded(
              child: Card(
                color: Colors.purple[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _pecahanList.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateColor.resolveWith((states) => Colors.purple[700]!),
                              border: TableBorder.all(color: Colors.white54),
                              columns: [
                                DataColumn(
                                    label: Center(
                                        child: Text('Pecahan Uang',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                                DataColumn(
                                    label: Center(
                                        child: Text('Jumlah',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                              ],
                              rows: _pecahanList.map((pecahan) {
                                return DataRow(cells: [
                                  DataCell(Center(
                                      child: Text(formatRupiah(pecahan.pecahan), // 📌 Format pecahan ke Rupiah
                                          style: TextStyle(color: Colors.white)))),
                                  DataCell(Center(
                                      child: Text('${pecahan.jumlah}', // 📌 Menampilkan jumlah
                                          style: TextStyle(color: Colors.white)))),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
