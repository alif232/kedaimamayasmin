import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart'; // Tambahkan paket DataTable2
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/laporanKeuanganController.dart';
import 'package:proyek2/models/pecahanModel.dart';
import 'package:proyek2/models/laporanKeuanganModel.dart';
import 'tambahPengeluaranAdmin.dart'; // Import the new file

class LaporanKeuanganAdmin extends StatefulWidget {
  @override
  _LaporanKeuanganAdminState createState() => _LaporanKeuanganAdminState();
}

class _LaporanKeuanganAdminState extends State<LaporanKeuanganAdmin> {
  final LaporanKeuanganController apiController = LaporanKeuanganController();
  late Future<List<Pecahan>> pecahanList;
  late Future<List<LaporanKeuangan>> laporanList;
  late Future<int> balance;

  @override
  void initState() {
    super.initState();
    pecahanList = apiController.fetchPecahan();
    laporanList = apiController.fetchLaporanKeuangan();
    balance = apiController.fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Keuangan'),
      ),
      backgroundColor: Colors.purple[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card untuk balance
            FutureBuilder<int>(
              future: balance,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  final balanceValue = snapshot.data ?? 0;
                  return Card(
                    color: Colors.purple[800],
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Balance:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 2,
                            ).format(balanceValue),
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            // Add Pengeluaran button
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TambahPengeluaran()),
                );

                // Refresh data if pengeluaran was added successfully
                if (result == true) {
                  setState(() {
                    laporanList = apiController.fetchLaporanKeuangan();
                    balance = apiController.fetchBalance();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text(
                'Tambah Pengeluaran',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pecahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<Pecahan>>(
                      future: pecahanList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
                        } else {
                          return DataTable2(
                            headingRowColor: MaterialStateProperty.all(Colors.purple[400]),
                            columnSpacing: 16.0,
                            minWidth: 400,
                            columns: const [
                              DataColumn(label: Text("Pecahan", style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text("Jumlah", style: TextStyle(color: Colors.white))),
                            ],
                            rows: snapshot.data!
                                .map((pecahan) => DataRow(cells: [
                                      DataCell(
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 2,
                                        ).format(pecahan.pecahan),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                      DataCell(Text("${pecahan.jumlah}", style: TextStyle(color: Colors.white))),
                                    ]))
                                .toList(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan Keuangan',
                    style: TextStyle(
                      color: Colors.white, // Change text color to white
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<LaporanKeuangan>>(
                      future: laporanList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white)); // Change error text color to white
                        } else {
                          return DataTable2(
                            headingRowColor:
                                MaterialStateProperty.all(Colors.purple[400]),
                            columnSpacing: 16.0,
                            minWidth: 600,
                            columns: const [
                              DataColumn(label: Text("Tanggal", style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text("Deskripsi", style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text("Jumlah", style: TextStyle(color: Colors.white))),
                            ],
                            rows: snapshot.data!
                                .map((laporan) => DataRow(cells: [
                                      DataCell(Text(laporan.tanggal, style: TextStyle(color: Colors.white))),
                                      DataCell(Text(laporan.deskripsi, style: TextStyle(color: Colors.white))),
                                      DataCell(
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 2,
                                        ).format(laporan.jumlah),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ]))
                                .toList(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}