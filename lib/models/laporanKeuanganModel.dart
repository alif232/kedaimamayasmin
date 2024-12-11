class LaporanKeuangan {
  final int idLaporan;
  final String tanggal;
  final String deskripsi;
  final int jumlah;

  LaporanKeuangan({
    required this.idLaporan,
    required this.tanggal,
    required this.deskripsi,
    required this.jumlah,
  });

  factory LaporanKeuangan.fromJson(Map<String, dynamic> json) {
    return LaporanKeuangan(
      idLaporan: int.tryParse(json['id_laporan']?.toString() ?? '0') ?? 0,
      tanggal: json['tanggal'] ?? 'No date',  // Default if null
      deskripsi: json['deskripsi'] ?? 'No description',  // Use a default value if null
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
    );
  }
}
