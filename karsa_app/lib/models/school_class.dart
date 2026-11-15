/// Kelas sekolah yang dikelola operator sekolah.
///
/// Daftar kelas disimpan di perangkat ini (kunci "@karsa-demo-v1") supaya
/// operator bisa menambah, mengubah, dan menghapus kelas beserta wali kelasnya.
class SchoolClass {
  final String id;
  final String name;

  /// Nama wali kelas. Kosong berarti belum ditentukan.
  final String teacherName;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.teacherName,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      teacherName: (json['teacherName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'teacherName': teacherName,
      };

  SchoolClass copyWith({
    String? id,
    String? name,
    String? teacherName,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
    );
  }
}
