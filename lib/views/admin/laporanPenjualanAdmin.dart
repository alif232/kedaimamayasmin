import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/laporanPenjualanController.dart';
import 'package:proyek2/models/laporanPenjualanModel.dart';

class LaporanPenjualanAdmin extends StatefulWidget {
  const LaporanPenjualanAdmin({Key? key}) : super(key: key);

  @override
  _LaporanPenjualanAdminState createState() => _LaporanPenjualanAdminState();
}

class _LaporanPenjualanAdminState extends State<LaporanPenjualanAdmin> {
  final LaporanPenjualanController _laporanController =
      LaporanPenjualanController();
  List<LaporanPenjualan> _laporanList = [];
  List<LaporanPenjualan> _filteredLaporanList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchLaporan();
  }

  // Function to load laporan penjualan data from the server
  void fetchLaporan() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final laporanList = await _laporanController.fetchLaporanPenjualan();
      setState(() {
        _laporanList = laporanList;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('Error while fetching laporan penjualan: $e');
      setState(() {
        _laporanList = [];
        _filteredLaporanList = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data laporan: $e')),
      );
    }
  }

  // Function to filter the laporan list based on search query
  void _applyFilter() {
    setState(() {
      _filteredLaporanList = _laporanList
          .where((laporan) =>
              laporan.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  // Function to show the order details
  void _showDetailPesanan(int idPesan) async {
    try {
      final detailPesanan =
          await _laporanController.fetchDetailPesanan(idPesan);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Detail Pesanan'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detailPesanan.map((detail) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menu: ${detail.namaMenu}'),
                      Text('Jumlah: ${detail.jumlah}'),
                      Text(
                        'Harga: ${NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 2,
                        ).format(detail.harga)}',
                      ),
                      Text(
                        'Total Harga: ${NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 2,
                        ).format(detail.totalHarga)}',
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tutup'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching detail pesanan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail pesanan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Penjualan'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.purple[900]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pesanan...',
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
                    _searchQuery = value;
                    _applyFilter();
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            // Table with DataTable2
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredLaporanList.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada laporan ditemukan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : DataTable2(
                        headingRowColor: MaterialStateProperty.all(Colors.purple[400]),
                        columnSpacing: 16.0,
                        minWidth: 700,
                        columns: const [
                          DataColumn(label: Text('No', style: TextStyle(color: Colors.white))), // Ganti menjadi No
                          DataColumn(label: Text('Nama', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Tanggal Order', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Total Harga', style: TextStyle(color: Colors.white))),
                        ],
                        rows: _filteredLaporanList.asMap().map((index, laporan) {
                          return MapEntry(
                            index,
                            DataRow(
                              color: MaterialStateProperty.all(Colors.purple[800]),
                              cells: [
                                DataCell(Text(
                                  (index + 1).toString(), // Gunakan indeks untuk nomor urut
                                  style: TextStyle(color: Colors.white),
                                )),
                                DataCell(
                                  Row(
                                    children: [
                                      Text(laporan.nama, style: TextStyle(color: Colors.white)),
                                      IconButton(
                                        icon: Icon(Icons.info, color: Colors.blue),
                                        onPressed: () {
                                          _showDetailPesanan(laporan.idPesan);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(laporan.tglOrder, style: TextStyle(color: Colors.white))),
                                DataCell(
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 2,
                                    ).format(laporan.totalHarga),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).values.toList(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
