import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proyek2/controllers/menuController.dart' as custom;
import 'package:proyek2/models/menuModel.dart';
import 'package:proyek2/views/kasir/detailPesananKasir.dart';

class DashboardKasir extends StatefulWidget {
  const DashboardKasir({Key? key}) : super(key: key);

  @override
  _DashboardKasirState createState() => _DashboardKasirState();
}

class _DashboardKasirState extends State<DashboardKasir> {
  final custom.MenuController _menuController = custom.MenuController();
  List<Menu> _makananList = [];
  List<Menu> _minumanList = [];
  List<Menu> _keranjang = [];
  List<Menu> _filteredMakananList = [];
  List<Menu> _filteredMinumanList = [];
  double _totalHarga = 0.0;
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  // Fetch menu data and separate by category
  void fetchMenu() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final menuList = await _menuController.fetchMenus();
      setState(() {
        _makananList = _sortMenu(
          menuList.where((menu) => menu.kategori.toLowerCase() == 'makanan').toList(),
        );
        _minumanList = _sortMenu(
          menuList.where((menu) => menu.kategori.toLowerCase() == 'minuman').toList(),
        );
        _filteredMakananList = List.from(_makananList);
        _filteredMinumanList = List.from(_minumanList);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat menu: $e')),
      );
    }
  }

  // Sort menu to move items with stock 0 to the end
  List<Menu> _sortMenu(List<Menu> menuList) {
    menuList.sort((a, b) {
      if (a.stok == 0 && b.stok != 0) return 1;
      if (a.stok != 0 && b.stok == 0) return -1;
      return 0;
    });
    return menuList;
  }

  // Filter menu based on search query
  void _filterMenu(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredMakananList = _makananList
          .where((menu) => menu.nama.toLowerCase().contains(_searchQuery))
          .toList();
      _filteredMinumanList = _minumanList
          .where((menu) => menu.nama.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  // Function to fetch image
  Future<Uint8List?> fetchImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes; // Return the image data as bytes
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
    return null; // Return null if there's an error
  }

  // Function to add item to cart or update quantity if already in cart
  void addToCart(Menu menu, int jumlah) {
    int index = _keranjang.indexWhere((item) => item.idMenu == menu.idMenu);
    if (index != -1) {
      setState(() {
        _keranjang[index].jumlahPesanan = jumlah; // Update quantity
        _totalHarga = _keranjang.fold(0, (total, item) => total + (item.harga * item.jumlahPesanan)); // Recalculate total
      });
    } else {
      setState(() {
        menu.jumlahPesanan = jumlah;
        _keranjang.add(menu);
        _totalHarga += (menu.harga * jumlah);
      });
    }
  }

  void _showQuantityDialog(Menu menu) {
    int jumlah = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Masukkan Jumlah'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Jumlah'),
            onChanged: (value) {
              jumlah = int.tryParse(value) ?? 1;
            },
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
                if (jumlah > menu.stok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Stok tidak mencukupi!')),
                  );
                } else {
                  addToCart(menu, jumlah);
                  Navigator.pop(context);
                }
              },
              child: Text('Tambah ke Keranjang'),
            ),
          ],
        );
      },
    );
  }

  // Function to log out (navigate to the root screen)
  void _logout() {
    Navigator.pushReplacementNamed(context, '/'); // Navigate to the root ("/") screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kasir'),
        actions: [
          // Logout Button
          TextButton(
            onPressed: _logout,
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.purple[900],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tampilan Menu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_keranjang.isNotEmpty)
                  Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2)
                        .format(_totalHarga),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _keranjang.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPesananKasir(
                                keranjang: _keranjang,
                                totalHarga: _totalHarga,
                              ),
                            ),
                          );
                        },
                  child: Text('Pesan Sekarang', style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
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
              onChanged: _filterMenu,
            ),
            SizedBox(height: 16),
            Divider(color: Colors.white, thickness: 1),
            SizedBox(height: 16),
            Text(
              'Makanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            _buildMenuGrid(_filteredMakananList),
            SizedBox(height: 16),
            Divider(color: Colors.white, thickness: 1),
            SizedBox(height: 16),
            Text(
              'Minuman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            _buildMenuGrid(_filteredMinumanList),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(List<Menu> menuList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final menu = menuList[index];
        return GestureDetector(
          onTap: () => _showQuantityDialog(menu),
          child: _buildMenuCard(menu),
        );
      },
    );
  }

  Widget _buildMenuCard(Menu menu) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<Uint8List?>(

              future: fetchImage('http://localhost/proyek/${menu.gambar}'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return Container(
                    color: Colors.grey,
                    child: Center(
                      child: Text('Tidak ada gambar'),
                    ),
                  );
                }
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.nama,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 2,
                  ).format(menu.harga),
                ),
                Text('Stok: ${menu.stok}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
