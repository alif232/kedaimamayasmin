class LaporanPenjualan {
  final int idPesan;
  final String nama;
  final String tglOrder;
  final int totalHarga;

  LaporanPenjualan({
    required this.idPesan,
    required this.nama,
    required this.tglOrder,
    required this.totalHarga,
  });

  factory LaporanPenjualan.fromJson(Map<String, dynamic> json) {
    return LaporanPenjualan(
      idPesan: int.tryParse(json['id_pesan']?.toString() ?? '0') ?? 0,
      nama: json['nama'],
      tglOrder: json['tgl_order'],
      totalHarga: int.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
    );
  }
}