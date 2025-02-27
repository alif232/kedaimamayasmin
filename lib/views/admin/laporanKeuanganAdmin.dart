import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/laporanKeuanganController.dart';
import 'package:proyek2/models/laporanKeuanganModel.dart';
import 'tambahPengeluaranAdmin.dart';

class LaporanKeuanganAdmin extends StatefulWidget {
  @override
  _LaporanKeuanganAdminState createState() => _LaporanKeuanganAdminState();
}

class _LaporanKeuanganAdminState extends State<LaporanKeuanganAdmin> {
  final LaporanKeuanganController apiController = LaporanKeuanganController();
  late Future<List<LaporanKeuangan>> laporanList;
  late Future<int> balance;
  String selectedMonth = DateFormat('MMMM').format(DateTime.now()); // Bulan saat ini

  @override
  void initState() {
    super.initState();
    laporanList = apiController.fetchLaporanKeuangan();
    balance = apiController.fetchBalance();
  }

  // Fungsi untuk memfilter laporan keuangan berdasarkan bulan yang dipilih
  List<LaporanKeuangan> filterByMonth(List<LaporanKeuangan> laporan) {
    return laporan.where((item) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(item.tanggal);
      return DateFormat('MMMM').format(date) == selectedMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laporan Keuangan')),
      backgroundColor: Colors.purple[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<int>(
              future: balance,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red));
                } else {
                  return Card(
                    color: Colors.purple[800],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Balance:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(snapshot.data ?? 0),
                            style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),

            // Dropdown untuk memilih bulan
            DropdownButton<String>(
            value: selectedMonth,
            dropdownColor: Colors.purple[800], // Warna latar dropdown agar serasi
            style: TextStyle(color: Colors.white), // Warna teks dropdown
            iconEnabledColor: Colors.white, // Warna ikon dropdown
            items: List.generate(12, (index) {
              String month = DateFormat('MMMM').format(DateTime(2025, index + 1));
              return DropdownMenuItem(
                value: month,
                child: Text(
                  month,
                  style: TextStyle(color: Colors.white), // Warna teks item dropdown
                ),
              );
            }),
            onChanged: (value) {
              setState(() {
                selectedMonth = value!;
              });
            },
          ),
            SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<LaporanKeuangan>>(
                future: laporanList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
                  } else {
                    List<LaporanKeuangan> filteredData = filterByMonth(snapshot.data ?? []);

                    // Menghitung total pengeluaran bulan tersebut
                    int totalpengeluaran = filteredData.fold(0, (sum, item) => sum + item.jumlah);

                    return Column(
                      children: [
                        Expanded(
                          child: DataTable2(
                            headingRowColor: MaterialStateProperty.all(Colors.purple[400]),
                            columnSpacing: 16.0,
                            minWidth: 600,
                            columns: const [
                              DataColumn(label: Text("Tanggal", style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text("Deskripsi", style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text("Jumlah", style: TextStyle(color: Colors.white))),
                            ],
                            rows: filteredData
                                .map((laporan) => DataRow(cells: [
                                      DataCell(Text(laporan.tanggal, style: TextStyle(color: Colors.white))),
                                      DataCell(Text(laporan.deskripsi, style: TextStyle(color: Colors.white))),
                                      DataCell(
                                        Text(
                                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(laporan.jumlah),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ]))
                                .toList(),
                          ),
                        ),

                        // Menampilkan total pengeluaran di bawah tabel
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            color: Colors.purple[800],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total pengeluaran Bulan $selectedMonth:",
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(
                                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(totalpengeluaran),
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
