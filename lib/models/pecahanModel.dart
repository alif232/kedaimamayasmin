class Pecahan {
  final int idPecahan;
  final int pecahan;
  final int jumlah;

  Pecahan({
    required this.idPecahan, 
    required this.pecahan, 
    required this.jumlah
  });

  factory Pecahan.fromJson(Map<String, dynamic> json) {
    return Pecahan(
      idPecahan: int.tryParse(json['id_pecahan']?.toString() ?? '0') ?? 0,
      pecahan: int.tryParse(json['pecahan']?.toString() ?? '0') ?? 0,
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
    );
  }
}
