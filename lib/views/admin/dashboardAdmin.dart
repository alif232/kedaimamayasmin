import 'package:flutter/material.dart';

class dashboardAdmin extends StatefulWidget {
  const dashboardAdmin({Key? key}) : super(key: key);

  @override
  State<dashboardAdmin> createState() => _dashboardAdminState();
}

class _dashboardAdminState extends State<dashboardAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.purple[900], // Warna ungu gelap untuk background
        child: Column(
          children: <Widget>[
            // Teks "Admin" di kiri atas
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 100.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // GridView untuk kartu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  _buildCard(
                    icon: Icon(Icons.menu, size: 40, color: Colors.white),
                    title: 'Kelola Menu',
                    subtitle: 'Tambah, Edit, Hapus Menu',
                    cardColor: Colors.purple[800]!, // Warna ungu muda untuk card
                    onTap: () {
                      Navigator.pushNamed(context, '/admin/kelolaMenu');
                    },
                  ),
                  _buildCard(
                    icon: Icon(Icons.inventory, size: 40, color: Colors.white),
                    title: 'Kelola Stok',
                    subtitle: 'Cek dan Update Stok',
                    cardColor: Colors.purple[800]!, // Warna ungu muda untuk card
                    onTap: () {
                      Navigator.pushNamed(context, '/admin/kelolaStok');
                    },
                  ),
                  _buildCard(
                    icon: Icon(Icons.pie_chart, size: 40, color: Colors.white),
                    title: 'Laporan Penjualan',
                    subtitle: 'Lihat Laporan Penjualan',
                    cardColor: Colors.purple[800]!, // Warna ungu muda untuk card
                    onTap: () {
                      Navigator.pushNamed(context, '/admin/laporanPenjualan');
                    },
                  ),
                  _buildCard(
                    icon: Icon(Icons.account_balance, size: 40, color: Colors.white),
                    title: 'Laporan Keuangan',
                    subtitle: 'Lihat Laporan Keuangan',
                    cardColor: Colors.purple[800]!, // Warna ungu muda untuk card
                    onTap: () {
                      Navigator.pushNamed(context, '/admin/laporanKeuangan');
                    },
                  ),
                  _buildCard(
                    icon: Icon(Icons.logout, size: 40, color: Colors.white), // Ganti icon menjadi Icons.logout
                    title: 'Logout',
                    subtitle: 'Keluar sebagai admin',
                    cardColor: Colors.purple[800]!, // Warna ungu muda untuk card
                    onTap: () {
                      Navigator.pushNamed(context, '/'); // Arahkan ke SplashScreen
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Icon icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap, // Action saat card di-tap
      splashColor: Colors.white.withOpacity(0.3), // Efek splash saat card di-tap
      highlightColor: Colors.white.withOpacity(0.1), // Efek highlight saat card di-tap
      child: Card(
        color: cardColor, // Set the card color to the passed color
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
