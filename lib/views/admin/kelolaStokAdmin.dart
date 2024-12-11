import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';  // Import DataTable2
import 'package:proyek2/controllers/stokController.dart';
import 'package:proyek2/models/stokModel.dart';

class KelolaStokAdmin extends StatefulWidget {
  const KelolaStokAdmin({Key? key}) : super(key: key);

  @override
  _KelolaStokAdminState createState() => _KelolaStokAdminState();
}

class _KelolaStokAdminState extends State<KelolaStokAdmin> {
  final StokController _stokController = StokController();
  List<Stok> _stokList = [];
  List<Stok> _filteredStokList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStok();
  }

  // Fungsi untuk memuat data stok dari server
  void fetchStok() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stokList = await _stokController.fetchStok();
      setState(() {
        _stokList = stokList;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('Error while fetching stok: $e');
      setState(() {
        _stokList = [];
        _filteredStokList = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data stok: $e')),
      );
    }
  }

  // Fungsi untuk memfilter data berdasarkan teks pencarian
  void _applyFilter() {
    setState(() {
      _filteredStokList = _stokList
          .where((stok) =>
              stok.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  // Fungsi untuk menambah stok
  void _addStok(Stok stok) async {
    int jumlah = 0;

    // Dialog input jumlah stok
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController jumlahController =
            TextEditingController();
        return AlertDialog(
          title: Text('Tambah Stok'),
          content: TextField(
            controller: jumlahController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Stok',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                jumlah = int.tryParse(jumlahController.text) ?? 0;
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );

    if (jumlah > 0) {
      try {
        await _stokController.addStok(stok.idMenu, jumlah);
        fetchStok(); // Refresh data stok
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok berhasil ditambahkan untuk ${stok.nama}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan stok: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Stok'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.purple[900]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget pencarian
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari menu...',
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
            // Tabel dengan DataTable2 yang responsif
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredStokList.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada stok ditemukan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : DataTable2(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.purple[400]),
                          columnSpacing: 16.0,
                          minWidth: 400,
                          columns: [
                            DataColumn(
                              label: Text('No', style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Nama', style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Stok', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          rows: _filteredStokList.asMap().map((index, stok) {
                            return MapEntry(
                              index,
                              DataRow(
                                color: MaterialStateProperty.all(Colors.purple[800]),
                                cells: [
                                  DataCell(Text((index + 1).toString(), style: TextStyle(color: Colors.white))),
                                  DataCell(Text(stok.nama, style: TextStyle(color: Colors.white))),
                                  DataCell(Row(
                                    children: [
                                      Expanded(child: Text(stok.stok.toString(), style: TextStyle(color: Colors.white))),
                                      DropdownButton<String>(
                                        value: 'Tambah',
                                        items: [
                                          DropdownMenuItem(
                                            value: 'Tambah',
                                            child: Text('Tambah'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          if (value == 'Tambah') {
                                            _addStok(stok);
                                          }
                                        },
                                        dropdownColor: Colors.purple[600],
                                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  )),
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
