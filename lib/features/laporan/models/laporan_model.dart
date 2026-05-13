class LaporanModel {
  final int id;
  final int userId;
  final int? kategoriId;
  final String judul;
  final String? deskripsi;
  final double latitude;
  final double longitude;
  final String? alamat;
  final String priority;
  final String status;
  final String? foto;
  final String createdAt;
  final String? updatedAt;

  LaporanModel({
    required this.id,
    required this.userId,
    this.kategoriId,
    required this.judul,
    this.deskripsi,
    required this.latitude,
    required this.longitude,
    this.alamat,
    required this.priority,
    required this.status,
    this.foto,
    required this.createdAt,
    this.updatedAt,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) => LaporanModel(
    id: json['id'],
    userId: json['user_id'],
    kategoriId: json['kategori_id'],
    judul: json['judul'] ?? '',
    deskripsi: json['deskripsi'],
    latitude: double.tryParse(json['latitude'].toString()) ?? 0,
    longitude: double.tryParse(json['longitude'].toString()) ?? 0,
    alamat: json['alamat'],
    priority: json['priority'] ?? 'sedang',
    status: json['status'] ?? 'pending',
    foto: json['foto'],
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'],
  );
}
