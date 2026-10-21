class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'student' ឬ 'lecturer'
  final String? studentCode; // លេខសម្គាល់សិស្ស (ឧ. STU001)
  final String? staffId; // លេខសម្គាល់គ្រូ/បុគ្គលិក (ឧ. STF001)
  final String? department; // មហាវិទ្យាល័យ / ដេប៉ាតឺម៉ង់
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentCode,
    this.staffId,
    this.department,
    this.phone,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isStudent => role == 'student';
  bool get isLecturer => role == 'lecturer' || role == 'teacher' || role == 'staff';

  // បំលែងពី JSON ដែល Laravel API បាញ់មក (Snake_case)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'student',
      studentCode: json['student_code'] as String?,
      staffId: json['staff_id'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  // បំលែងទៅជា JSON សម្រាប់ផ្ញើទៅ Laravel API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'student_code': studentCode,
      'staff_id': staffId,
      'department': department,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
