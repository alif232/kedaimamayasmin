import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyek2/controllers/laporanPenjualanController.dart';
import 'package:intl/intl.dart';

class GrafikPenjualanPage extends StatefulWidget {
  @override
  _GrafikPenjualanPageState createState() => _GrafikPenjualanPageState();
}

class _GrafikPenjualanPageState extends State<GrafikPenjualanPage> {
  final LaporanPenjualanController _controller = LaporanPenjualanController();
  Map<String, int> jumlahPesananMingguan = {};

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedWeek = 1;

  @override
  void initState() {
    super.initState();
    fetchDataMingguan();
  }

  // Ambil jumlah pesanan per hari selama seminggu
  void fetchDataMingguan() async {
    DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    DateTime startOfWeek = firstDayOfMonth.add(Duration(days: (selectedWeek - 1) * 7));

    Map<String, int> dataMingguan = {};

    for (int i = 0; i < 7; i++) {
      DateTime targetDate = startOfWeek.add(Duration(days: i));
      if (targetDate.month != selectedMonth) break;
      String formattedDate = DateFormat('yyyy-MM-dd').format(targetDate);
      int totalPesanan = await _controller.fetchTotalPesananByDate(formattedDate);
      dataMingguan[DateFormat('E').format(targetDate)] = totalPesanan;
    }

    setState(() {
      jumlahPesananMingguan = dataMingguan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        title: Text('Grafik Pesanan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Dropdown Filter Tahun, Bulan, Minggu
            Card(
              color: Colors.purple[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Pilihan Tahun
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: _dropdownDecoration(),
                      dropdownColor: Colors.purple[700],
                      style: TextStyle(color: Colors.white),
                      items: List.generate(5, (index) => DateTime.now().year - index)
                          .map((year) => DropdownMenuItem(value: year, child: Text(year.toString())))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value!;
                          fetchDataMingguan();
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Pilihan Bulan
                    DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: _dropdownDecoration(),
                      dropdownColor: Colors.purple[700],
                      style: TextStyle(color: Colors.white),
                      items: List.generate(12, (index) => index + 1)
                          .map((month) => DropdownMenuItem(
                                value: month,
                                child: Text(DateFormat('MMMM').format(DateTime(0, month))),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value!;
                          selectedWeek = 1; // Reset ke minggu pertama saat bulan diubah
                          fetchDataMingguan();
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // 🔹 Pilihan Minggu (Sekarang ada Minggu ke-5)
                    DropdownButtonFormField<int>(
                      value: selectedWeek,
                      decoration: _dropdownDecoration(),
                      dropdownColor: Colors.purple[700],
                      style: TextStyle(color: Colors.white),
                      items: List.generate(5, (index) => index + 1) // ✅ Tambahkan Minggu ke-5
                          .map((week) => DropdownMenuItem(value: week, child: Text("Minggu ke-$week")))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedWeek = value!;
                          fetchDataMingguan();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // 🔹 Grafik Pesanan Mingguan
            Expanded(
              child: jumlahPesananMingguan.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Card(
                      color: Colors.purple[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false), // Menghapus angka di kiri
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(color: Colors.white, fontSize: 12), // Label angka di kanan putih
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    List<String> days = jumlahPesananMingguan.keys.toList();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        days[value.toInt()],
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    );
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.white.withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.white.withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                            ),
                            barGroups: jumlahPesananMingguan.entries.map((entry) {
                              return BarChartGroupData(
                                x: jumlahPesananMingguan.keys.toList().indexOf(entry.key),
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    color: Colors.blueAccent,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
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

  // Fungsi untuk mendesain dropdown
  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.purple[700],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }
}
