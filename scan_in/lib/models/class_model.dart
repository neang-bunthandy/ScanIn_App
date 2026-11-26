// Class data model and JSON serialization.
class ClassModel {
  final int id;
  final int lecturerId;
  final String? lecturerName;
  final String? teacherEmail;
  final String? teacherPhone;
  final String? description;
  final String subjectName;
  final String subjectCode;
  final String? department;
  final String? generation;
  final int? yearLevel;
  final String room;
  final String dayOfWeek;
  final String time;
  final String? classDate;
  final String semester;
  final String academicYear;
  final int studentCount;
  final int completedSessions;
  final int totalSessions;
  final String? qrToken;
  final bool isQrActive;
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
    this.department,
    this.generation,
    this.yearLevel,
    required this.room,
    required this.dayOfWeek,
    required this.time,
    this.classDate,
    required this.semester,
    required this.academicYear,
    this.studentCount = 0,
    this.completedSessions = 0,
    this.totalSessions = 15,
    this.qrToken,
    this.isQrActive = false,
    this.createdAt,
  });

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
      department: json['department'] as String?,
      generation: json['generation'] as String?,
      yearLevel: json['year_level'] is int
          ? json['year_level'] as int
          : int.tryParse(json['year_level']?.toString() ?? ''),
      room: json['room'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      time: json['time'] as String? ?? '',
      classDate: json['class_date'] as String?,
      semester: json['semester'] as String? ?? 'ឆមាសទី ១',
      academicYear: json['academic_year'] as String? ?? '2026-2027',
      studentCount: json['student_count'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 15,
      qrToken: json['qr_token'] as String?,
      isQrActive: json['is_qr_active'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

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
      'department': department,
      'generation': generation,
      'year_level': yearLevel,
      'room': room,
      'day_of_week': dayOfWeek,
      'time': time,
      'class_date': classDate,
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

  ClassModel copyWith({
    int? id,
    int? lecturerId,
    String? lecturerName,
    String? teacherEmail,
    String? teacherPhone,
    String? description,
    String? subjectName,
    String? subjectCode,
    String? department,
    String? generation,
    int? yearLevel,
    String? room,
    String? dayOfWeek,
    String? time,
    String? classDate,
    String? semester,
    String? academicYear,
    int? studentCount,
    int? completedSessions,
    int? totalSessions,
    String? qrToken,
    bool? isQrActive,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      lecturerId: lecturerId ?? this.lecturerId,
      lecturerName: lecturerName ?? this.lecturerName,
      teacherEmail: teacherEmail ?? this.teacherEmail,
      teacherPhone: teacherPhone ?? this.teacherPhone,
      description: description ?? this.description,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      department: department ?? this.department,
      generation: generation ?? this.generation,
      yearLevel: yearLevel ?? this.yearLevel,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      time: time ?? this.time,
      classDate: classDate ?? this.classDate,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      studentCount: studentCount ?? this.studentCount,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      qrToken: qrToken ?? this.qrToken,
      isQrActive: isQrActive ?? this.isQrActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
