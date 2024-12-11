class DetailPesanan {
  final int idMenu;
  final String namaMenu;
  final int jumlah;
  final int harga;
  final int totalHarga;

  DetailPesanan({
    required this.idMenu,
    required this.namaMenu,
    required this.jumlah,
    required this.harga,
    required this.totalHarga,
  });

  factory DetailPesanan.fromJson(Map<String, dynamic> json) {
    return DetailPesanan(
      idMenu: int.tryParse(json['id_menu']?.toString() ?? '0') ?? 0,
      namaMenu: json['nama_menu'] ?? 'Unknown',  // Default to 'Unknown' if null
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      harga: int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      totalHarga: int.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
    );
  }
}
