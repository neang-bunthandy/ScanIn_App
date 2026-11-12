class UserModel {
  final int id;
  final String name;
  final String? latinName; // ឈ្មោះជាអក្សរឡាតាំង
  final String email;
  final String role; // 'student' ឬ 'lecturer'
  final String? studentCode; // លេខសម្គាល់សិស្ស (ឧ. STU001)
  final String? staffId; // លេខសម្គាល់គ្រូ/បុគ្គលិក (ឧ. STF001)
  final String? department; // មហាវិទ្យាល័យ / ដេប៉ាតឺម៉ង់
  final String? generation; // ជំនាន់ (ឧ. Gen 15)
  final String? intakeYear; // ចាប់ពីឆ្នាំ (ឧ. 2024)
  final int? yearLevel; // ឆ្នាំទី (1-4)
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.latinName,
    required this.email,
    required this.role,
    this.studentCode,
    this.staffId,
    this.department,
    this.generation,
    this.intakeYear,
    this.yearLevel,
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
      latinName: json['latin_name'] as String?,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'student',
      studentCode: json['student_code'] as String?,
      staffId: json['staff_id'] as String?,
      department: json['department'] as String?,
      generation: json['generation'] as String?,
      intakeYear: json['intake_year']?.toString(),
      yearLevel: json['year_level'] is int
          ? json['year_level'] as int
          : int.tryParse(json['year_level']?.toString() ?? ''),
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
      'latin_name': latinName,
      'email': email,
      'role': role,
      'student_code': studentCode,
      'staff_id': staffId,
      'department': department,
      'generation': generation,
      'intake_year': intakeYear,
      'year_level': yearLevel,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
