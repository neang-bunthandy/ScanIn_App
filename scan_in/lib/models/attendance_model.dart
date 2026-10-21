class AttendanceModel {
  final int id;
  final int classId;
  final int studentId;
  final String studentName;
  final String studentCode;
  final String status; // 'present' (មក), 'late' (យឺត), 'absent' (អវត្តមាន)
  final DateTime? scannedAt;
  final String date; // ឧ. 2026-10-15
  final String? note;
  final DateTime? createdAt;

  const AttendanceModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.status,
    this.scannedAt,
    required this.date,
    this.note,
    this.createdAt,
  });

  bool get isPresent => status == 'present';
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';

  // ឈ្មោះស្ថានភាពជាភាសាខ្មែរ
  String get statusKhmer {
    switch (status) {
      case 'present':
        return 'វត្តមាន';
      case 'late':
        return 'យឺត';
      case 'absent':
        return 'អវត្តមាន';
      default:
        return status;
    }
  }

  // បំលែងពី JSON របស់ Laravel API (Snake_case)
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String? ?? '',
      studentCode: json['student_code'] as String? ?? '',
      status: json['status'] as String? ?? 'present',
      scannedAt: json['scanned_at'] != null
          ? DateTime.tryParse(json['scanned_at'] as String)
          : null,
      date: json['date'] as String? ?? '',
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  // បំលែងទៅជា JSON សម្រាប់ផ្ញើទៅ Laravel API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'student_id': studentId,
      'student_name': studentName,
      'student_code': studentCode,
      'status': status,
      'scanned_at': scannedAt?.toIso8601String(),
      'date': date,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
