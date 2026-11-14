/// Data resmi satu siswa.
///
/// Sebelumnya daftar siswa hanya berupa daftar statis di dalam widget. Role
/// operator sekolah memerlukan data siswa yang bisa ditambah, diubah, dan
/// dihapus, jadi siswanya menjadi entri tersendiri di dalam store
/// (`KarsaStoreData.roster`).
class StudentProfile {
  final String id;
  final String nisn;
  final String name;
  final String className;

  /// 'L' atau 'P'.
  final String gender;

  final String parentName;
  final bool active;

  const StudentProfile({
    required this.id,
    required this.nisn,
    required this.name,
    required this.className,
    this.gender = 'L',
    this.parentName = '',
    this.active = true,
  });

  String get genderLabel => gender.toUpperCase() == 'P' ? 'Perempuan' : 'Laki-laki';

  StudentProfile copyWith({
    String? id,
    String? nisn,
    String? name,
    String? className,
    String? gender,
    String? parentName,
    bool? active,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      nisn: nisn ?? this.nisn,
      name: name ?? this.name,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      parentName: parentName ?? this.parentName,
      active: active ?? this.active,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: (json['id'] ?? '').toString(),
      nisn: (json['nisn'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      className: (json['className'] ?? 'Kelas 1').toString(),
      gender: (json['gender'] ?? 'L').toString(),
      parentName: (json['parentName'] ?? '').toString(),
      active: json['active'] != false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nisn': nisn,
        'name': name,
        'className': className,
        'gender': gender,
        'parentName': parentName,
        'active': active,
      };
}
