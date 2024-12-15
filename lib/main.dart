import 'package:proyek2/state_util.dart';
import 'package:proyek2/core.dart';
import 'package:flutter/material.dart';
import 'package:proyek2/views/splashScreen.dart';
import 'package:proyek2/views/admin/dashboardAdmin.dart';
import 'package:proyek2/views/admin/kelolaMenuAdmin.dart';
import 'package:proyek2/views/admin/kelolaStokAdmin.dart';
import 'package:proyek2/views/admin/laporanPenjualanAdmin.dart';
import 'package:proyek2/views/admin/laporanKeuanganAdmin.dart';
import 'package:proyek2/views/kasir/dashboardKasir.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kedai Mama Yasmin',
      navigatorKey: Get.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Nunito',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/admin': (context) => dashboardAdmin(),
        '/admin/kelolaMenu': (context) => KelolaMenuAdmin(),
        '/admin/kelolaStok': (context) => KelolaStokAdmin(),
        '/admin/laporanPenjualan': (context) => LaporanPenjualanAdmin(),
        '/admin/laporanKeuangan': (context) => LaporanKeuanganAdmin(),
        '/kasir': (context) => DashboardKasir(),
      }, 
    );
  }
}
