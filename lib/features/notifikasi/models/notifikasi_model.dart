class NotifikasiModel {
  final int id;
  final int userId;
  final int? laporanId;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  NotifikasiModel({
    required this.id,
    required this.userId,
    this.laporanId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse('${json['user_id']}') ?? 0,
      laporanId: json['laporan_id'] == null
          ? null
          : (json['laporan_id'] is int
              ? json['laporan_id']
              : int.tryParse('${json['laporan_id']}')),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }
}
