import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/laporanPenjualanController.dart';
import 'package:proyek2/models/laporanPenjualanModel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';  // For kIsWeb
import 'package:html/html.dart' as html; // For creating a download link
import 'package:printing/printing.dart'; // Importing the printing package

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

  // Show month selection dialog
  void _showMonthDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedMonth = DateTime.now().month;
        return AlertDialog(
          title: Text('Pilih Bulan'),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(12, (index) {
                return ListTile(
                  title: Text(DateFormat('MMMM').format(DateTime(0, index + 1))),
                  onTap: () {
                    selectedMonth = index + 1;
                    Navigator.pop(context);
                    _generatePDF(selectedMonth); // Trigger PDF generation
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // Generate PDF report for selected month
  void _generatePDF(int month) async {
    final pdf = pw.Document();

    // Filter reports by month
    List<LaporanPenjualan> filteredReports = _laporanList.where((laporan) {
      DateTime orderDate = DateFormat('yyyy-MM-dd').parse(laporan.tglOrder);
      return orderDate.month == month;
    }).toList();

    // Add content to the PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Laporan Penjualan Bulan: ${DateFormat('MMMM yyyy').format(DateTime(0, month))}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                ['No', 'Nama', 'Tanggal Order', 'Total Harga'],
                ...filteredReports.map((laporan) {
                  return [
                    laporan.idPesan.toString(),
                    laporan.nama,
                    laporan.tglOrder,
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(laporan.totalHarga),
                  ];
                }).toList(),
              ],
            ),
          ],
        );
      },
    ));

    // Convert PDF to bytes
    final pdfBytes = await pdf.save();

    // For Web, use HTML package to trigger download
    if (kIsWeb) {
      final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'laporan_penjualan.pdf'
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile, use Printing.layoutPdf to save or print
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
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
            // Button for printing
            ElevatedButton(
              onPressed: () {
                _showMonthDialog();
              },
              child: Text('Cetak Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}
