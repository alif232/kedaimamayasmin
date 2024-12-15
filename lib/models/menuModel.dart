class Menu {
  final int idMenu;
  final String nama;
  final String kategori;
  final int harga;
  int stok;
  int jumlahPesanan = 0;
  int jumlah = 0;
  final String? gambar;
  final DateTime createdAt;
  final DateTime updatedAt;

  Menu({
    required this.idMenu,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.gambar,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory untuk membuat objek dari JSON
  factory Menu.fromJson(Map<String, dynamic> json) {
  return Menu(
    idMenu: int.tryParse(json['id_menu']?.toString() ?? '0') ?? 0,
    nama: json['nama'] ?? '',
    kategori: json['kategori'] ?? '',
    harga: int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
    stok: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
    gambar: json['gambar'] ?? '',
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
  );
}

  // Metode toJson untuk mengonversi objek menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id_menu': idMenu.toString(), // Ubah ke string jika API membutuhkan string
      'nama': nama,
      'kategori': kategori,
      'harga': harga.toString(),
      'stok': stok.toString(),
      'gambar': gambar,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}