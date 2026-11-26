// User data model and JSON serialization.
class UserModel {
  final int id;
  final String name;
  final String? latinName;
  final String email;
  final String role;
  final String? studentCode;
  final String? staffId;
  final String? department;
  final String? generation;
  final String? intakeYear;
  final int? yearLevel;
  final String status;
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
    this.status = 'active',
    this.phone,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isStudent => role == 'student';
  bool get isLecturer => role == 'lecturer' || role == 'teacher' || role == 'staff';
  bool get isMasterAdmin => role == 'admin';
  bool get isSubAdmin => role == 'sub_admin';
  bool get isAdmin => role == 'admin' || role == 'sub_admin';

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
      status: json['status'] as String? ?? 'active',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

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
      'status': status,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
