class AnnouncementItem {
  final String id;
  final String category;
  final String title;
  final String detail;
  final String body;
  final String className;

  const AnnouncementItem({
    required this.id,
    required this.category,
    required this.title,
    required this.detail,
    required this.body,
    required this.className,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: (json['id'] ?? '').toString(),
      category: (json['category'] ?? 'PENGUMUMAN').toString(),
      title: (json['title'] ?? '').toString(),
      detail: (json['detail'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      className: (json['className'] ?? 'Semua kelas').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'category': category,
        'title': title,
        'detail': detail,
        'body': body,
        'className': className,
      };
}
