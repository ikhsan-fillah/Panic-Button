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
  final String? catatan;
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
    this.catatan,
    this.foto,
    required this.createdAt,
    this.updatedAt,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    String? extractCatatan() {
      final direct = json['catatan'] ?? json['catatan_penanganan'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString();
      }

      final latest = json['latest_penanganan'] ?? json['penanganan_terbaru'];
      if (latest is Map) {
        final c = latest['catatan'] ?? latest['keterangan'];
        if (c != null && c.toString().trim().isNotEmpty) {
          return c.toString();
        }
      }

      final penanganan = json['penanganan'];
      if (penanganan is Map) {
        final c = penanganan['catatan'] ?? penanganan['keterangan'];
        if (c != null && c.toString().trim().isNotEmpty) {
          return c.toString();
        }
      }
      if (penanganan is List && penanganan.isNotEmpty) {
        final firstMap = penanganan.first;
        if (firstMap is Map) {
          final c = firstMap['catatan'] ?? firstMap['keterangan'];
          if (c != null && c.toString().trim().isNotEmpty) {
            return c.toString();
          }
        }
      }
      return null;
    }

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
      catatan: extractCatatan(),
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
    'catatan': catatan,
    'foto': foto,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
