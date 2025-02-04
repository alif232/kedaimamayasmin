import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/views/kasir/dashboardKasir.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class StrukPembelian extends StatelessWidget {
  final String tanggalPesan;
  final String namaPemesan;
  final List<Map<String, dynamic>> daftarProduk;
  final double totalHarga;
  final double uangDiberikan;
  final double uangKembali;

  const StrukPembelian({
    Key? key,
    required this.tanggalPesan,
    required this.namaPemesan,
    required this.daftarProduk,
    required this.totalHarga,
    required this.uangDiberikan,
    required this.uangKembali,
  }) : super(key: key);

  Future<void> _printStruk() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Struk Pembelian', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Tanggal Pesan: $tanggalPesan', style: pw.TextStyle(fontSize: 16)),
                pw.Text('Nama Pemesan: $namaPemesan', style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                pw.Text('Produk yang Dipesan:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.ListView.builder(
                  itemCount: daftarProduk.length,
                  itemBuilder: (context, index) {
                    final produk = daftarProduk[index];
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${produk['namaProduk']} (${produk['jumlah']}x)', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(produk['total'])}', style: pw.TextStyle(fontSize: 14)),
                      ],
                    );
                  },
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Harga:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(totalHarga)}', style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Uang Diberikan:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(uangDiberikan)}', style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Uang Kembali:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(uangKembali)}', style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        title: Text('Struk Pembelian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal Pesan: $tanggalPesan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Nama Pemesan: $namaPemesan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Produk yang Dipesan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: daftarProduk.length,
                itemBuilder: (context, index) {
                  final produk = daftarProduk[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(produk['namaProduk'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah: ${produk['jumlah']}'),
                          Text('Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(produk['harga'])}'),
                        ],
                      ),
                      trailing: Text(
                        '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(produk['total'])}',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                  'Total Harga:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(totalHarga)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uang Diberikan:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(uangDiberikan)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Kembalian:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(uangKembali)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _printStruk,
                    child: Text('Print Struk', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardKasir(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text('Kembali', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
