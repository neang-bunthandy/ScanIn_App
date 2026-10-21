class ClassModel {
  final int id;
  final int lecturerId;
  final String? lecturerName; // ឈ្មោះគ្រូបង្រៀន (ឧ. Mr. Dara)
  final String? teacherEmail;
  final String? teacherPhone;
  final String? description; // ការពិពណ៌នាមុខវិជ្ជា
  final String subjectName; // ឈ្មោះមុខវិជ្ជា
  final String subjectCode; // កូដមុខវិជ្ជា (ឧ. CS101)
  final String room; // បន្ទប់រៀន (ឧ. A201)
  final String dayOfWeek; // ថ្ងៃរៀន (ឧ. ចន្ទ, អង្គារ)
  final String time; // ម៉ោងរៀន (ឧ. 08:00 - 10:00)
  final String semester; // ឆមាស
  final String academicYear; // ឆ្នាំសិក្សា
  final int studentCount; // ចំនួនសិស្សសរុប
  final int completedSessions; // ចំនួនសប្តាហ៍ដែលបានរៀន
  final int totalSessions; // ចំនួនសប្តាហ៍សរុប
  final String? qrToken; // Token សម្រាប់ QR កត់វត្តមាន
  final bool isQrActive; // ស្ថានភាព QR
  final DateTime? createdAt;

  const ClassModel({
    required this.id,
    required this.lecturerId,
    this.lecturerName,
    this.teacherEmail,
    this.teacherPhone,
    this.description,
    required this.subjectName,
    required this.subjectCode,
    required this.room,
    required this.dayOfWeek,
    required this.time,
    required this.semester,
    required this.academicYear,
    this.studentCount = 0,
    this.completedSessions = 6,
    this.totalSessions = 15,
    this.qrToken,
    this.isQrActive = false,
    this.createdAt,
  });

  // បំលែងពី JSON របស់ Laravel API (Snake_case ឬ Eloquent Relationship)
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int,
      lecturerId: json['lecturer_id'] as int? ?? 1,
      lecturerName: json['lecturer_name'] as String? ??
          (json['lecturer'] is Map ? json['lecturer']['name'] as String? : null),
      teacherEmail: json['teacher_email'] as String?,
      teacherPhone: json['teacher_phone'] as String?,
      description: json['description'] as String?,
      subjectName: json['subject_name'] as String,
      subjectCode: json['subject_code'] as String,
      room: json['room'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      time: json['time'] as String? ?? '',
      semester: json['semester'] as String? ?? 'ឆមាសទី ១',
      academicYear: json['academic_year'] as String? ?? '2026-2027',
      studentCount: json['student_count'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 6,
      totalSessions: json['total_sessions'] as int? ?? 15,
      qrToken: json['qr_token'] as String?,
      isQrActive: json['is_qr_active'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  // បំលែងទៅជា JSON សម្រាប់ផ្ញើទៅ Laravel API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lecturer_id': lecturerId,
      'lecturer_name': lecturerName,
      'teacher_email': teacherEmail,
      'teacher_phone': teacherPhone,
      'description': description,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'room': room,
      'day_of_week': dayOfWeek,
      'time': time,
      'semester': semester,
      'academic_year': academicYear,
      'student_count': studentCount,
      'completed_sessions': completedSessions,
      'total_sessions': totalSessions,
      'qr_token': qrToken,
      'is_qr_active': isQrActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
