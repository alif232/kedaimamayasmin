import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:proyek2/controllers/laporanPenjualanController.dart';
import 'package:proyek2/models/laporanPenjualanModel.dart';
import 'package:proyek2/views/admin/GrafikPenjualanPage.dart'; 

class LaporanPenjualanAdmin extends StatefulWidget {
  const LaporanPenjualanAdmin({Key? key}) : super(key: key);

  @override
  _LaporanPenjualanAdminState createState() => _LaporanPenjualanAdminState();
}

class _LaporanPenjualanAdminState extends State<LaporanPenjualanAdmin> {
  final LaporanPenjualanController _laporanController = LaporanPenjualanController();
  List<LaporanPenjualan> _laporanList = [];
  List<LaporanPenjualan> _filteredLaporanList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  int _totalPenjualan = 0;

  @override
  void initState() {
    super.initState();
    fetchLaporan();
  }

  // Fetch laporan berdasarkan tanggal yang dipilih
  void fetchLaporan() async {
    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final laporanList = await _laporanController.fetchLaporanPenjualanByDate(formattedDate);
      setState(() {
        _laporanList = laporanList;
        _applyFilter();
        _calculateTotalPenjualan(); // Hitung total penjualan setelah fetch data
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

  // Fungsi untuk menampilkan date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        fetchLaporan(); // Fetch ulang data setelah memilih tanggal
      });
    }
  }

  // Filter laporan berdasarkan query pencarian
  void _applyFilter() {
    setState(() {
      _filteredLaporanList = _laporanList.where((laporan) =>
          laporan.nama.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      _calculateTotalPenjualan(); // Hitung total penjualan setelah filter
    });
  }

  // Hitung total penjualan
  void _calculateTotalPenjualan() {
    setState(() {
      _totalPenjualan = _filteredLaporanList.fold(0, (sum, laporan) => sum + laporan.totalHarga);
    });
  }

  // Tampilkan detail pesanan
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
            // Date Picker Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => selectDate(context),
                  child: Text('Pilih Tanggal'),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Search field
            TextField(
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
            SizedBox(height: 16.0),

            // Tambahkan ikon grafik di samping total penjualan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Penjualan Hari Ini: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(_totalPenjualan)}',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.bar_chart, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GrafikPenjualanPage()),
                    );
                  },
                ),
              ],
            ),


            // Tabel Laporan Penjualan
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
                            DataColumn(label: Text('No', style: TextStyle(color: Colors.white))),
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
                                    (index + 1).toString(),
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
