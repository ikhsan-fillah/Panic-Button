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

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      kategoriId: json['kategori_id'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'],
      // Handle string atau double dari API
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      alamat: json['alamat'],
      priority: json['priority'] ?? 'sedang',
      status: json['status'] ?? 'pending',
      foto: json['foto'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'kategori_id': kategoriId,
    'judul': judul,
    'deskripsi': deskripsi,
    'latitude': latitude,
    'longitude': longitude,
    'alamat': alamat,
    'priority': priority,
    'status': status,
    'foto': foto,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
