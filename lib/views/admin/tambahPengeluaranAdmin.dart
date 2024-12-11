import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/laporanKeuanganController.dart';
import 'package:proyek2/models/pecahanModel.dart';

class TambahPengeluaran extends StatefulWidget {
  @override
  _TambahPengeluaranState createState() => _TambahPengeluaranState();
}

class _TambahPengeluaranState extends State<TambahPengeluaran> {
  final LaporanKeuanganController apiController = LaporanKeuanganController();
  late Future<List<Pecahan>> pecahanList;
  List<Pecahan> selectedPecahans = [];
  List<int> pecahanAmounts = [];
  final TextEditingController deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pecahanList = apiController.fetchPecahan();
  }

  void togglePecahan(Pecahan pecahan, int amount) {
    setState(() {
      int index = selectedPecahans.indexOf(pecahan);
      if (index != -1) {
        int newAmount = pecahanAmounts[index] + amount;
        if (newAmount <= pecahan.jumlah) {
          pecahanAmounts[index] = newAmount;
        } else {
          showAmountAlert(context, pecahan);
        }
      } else {
        if (amount <= pecahan.jumlah) {
          selectedPecahans.add(pecahan);
          pecahanAmounts.add(amount);
        } else {
          showAmountAlert(context, pecahan);
        }
      }
    });
  }

  void submitPengeluaran() {
    if (selectedPecahans.isEmpty || deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select pecahan and enter a description")),
      );
    } else {
      int totalAmount = calculateTotalAmount();
      apiController
        .addPengeluaran(
          deskripsiController.text,
          selectedPecahans,
          pecahanAmounts,
          totalAmount,
        )
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pengeluaran added successfully")));
      Navigator.pop(context, true); // Return true to indicate success
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")));
    });
    }
  }

  int calculateTotalAmount() {
    int total = 0;
    for (int i = 0; i < selectedPecahans.length; i++) {
      total += selectedPecahans[i].pecahan * pecahanAmounts[i];
    }
    return total;
  }

  Future<void> showAmountAlert(BuildContext context, Pecahan pecahan) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Jumlah yang dimasukkan melebihi jumlah yang tersedia. Max: ${pecahan.jumlah}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Pengeluaran'),
      ),
      backgroundColor: Colors.purple[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deskripsi Input Card
              Card(
                color: Colors.purple[800],
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deskripsi Pengeluaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: deskripsiController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan deskripsi...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Pecahan List Card
              FutureBuilder<List<Pecahan>>(
                future: pecahanList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text(
                      "Error: ${snapshot.error}",
                      style: TextStyle(color: Colors.red),
                    );
                  } else if (snapshot.hasData) {
                    List<Pecahan> pecahanData = snapshot.data!;
                    return Card(
                      color: Colors.purple[800],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pecahan:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: pecahanData.length,
                              itemBuilder: (context, index) {
                                final pecahan = pecahanData[index];
                                return ListTile(
                                  title: Text(
                                    NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 2,
                                    ).format(pecahan.pecahan),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    "Jumlah: ${pecahan.jumlah}",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Text(
                                    pecahanAmounts.isNotEmpty &&
                                            selectedPecahans.contains(pecahan)
                                        ? "${pecahanAmounts[selectedPecahans.indexOf(pecahan)]}"
                                        : "0",
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                onTap: () async {
                                  int? amount = await showDialog<int>(
                                    context: context,
                                    builder: (context) {
                                      int? localAmount;
                                      return AlertDialog(
                                        title: Text("Enter Amount"),
                                        content: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(hintText: 'Enter amount'),
                                          onChanged: (value) {
                                            localAmount = int.tryParse(value);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, localAmount);
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (amount != null && amount > 0) {
                                    if (amount > pecahan.jumlah) {
                                      showAmountAlert(context, pecahan);
                                    } else {
                                      togglePecahan(pecahan, amount); // Gunakan operator `!` untuk memastikan nilai tidak null
                                    }
                                  }
                                }
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
              SizedBox(height: 20),

              // Total Uang dan Submit Button
              Card(
                color: Colors.purple[800],
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Uang: ${NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 2,
                        ).format(calculateTotalAmount())}",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submitPengeluaran,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Tambah Pengeluaran',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
