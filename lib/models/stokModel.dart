class Stok {
  final int idMenu;
  final String nama;
  final int stok;

  Stok({
    required this.idMenu,
    required this.nama,
    required this.stok,
  });

  factory Stok.fromJson(Map<String, dynamic> json) {
    // Coba mengonversi stok ke tipe int dengan aman menggunakan tryParse
    return Stok(
      idMenu: int.tryParse(json['id_menu']?.toString() ?? '0') ?? 0,
      nama: json['nama'],
      stok: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
    );
  }
}
