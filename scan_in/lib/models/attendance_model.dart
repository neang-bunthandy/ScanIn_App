// Attendance record model and status helpers.
import '../core/app_language.dart';

class AttendanceModel {
  final int id;
  final int classId;
  final String? subjectName;
  final String? subjectCode;
  final String? room;
  final String? time;
  final int studentId;
  final String studentName;
  final String studentCode;
  final String status;
  final DateTime? scannedAt;
  final String date;
  final String? note;
  final DateTime? createdAt;

  const AttendanceModel({
    required this.id,
    required this.classId,
    this.subjectName,
    this.subjectCode,
    this.room,
    this.time,
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

  String get statusText {
    if (AppLanguage.isEnglish) {
      switch (status) {
        case 'present':
          return 'Present';
        case 'late':
          return 'Late';
        case 'absent':
          return 'Absent';
        default:
          return status;
      }
    }
    return statusKhmer;
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      subjectName: json['subject_name'] as String? ??
          json['class_name'] as String? ??
          (json['class'] is Map ? json['class']['subject_name'] as String? : null),
      subjectCode: json['subject_code'] as String? ??
          (json['class'] is Map ? json['class']['subject_code'] as String? : null),
      room: json['room'] as String? ??
          (json['class'] is Map ? json['class']['room'] as String? : null),
      time: json['time'] as String? ??
          (json['class'] is Map ? json['class']['time'] as String? : null),
      studentId: json['student_id'] as int? ?? (json['user_id'] as int? ?? 0),
      studentName: (json['student_name'] ??
          (json['student'] is Map ? json['student']['name'] : null)) as String? ?? '',
      studentCode: (json['student_code'] ??
          (json['student'] is Map ? json['student']['student_code'] : null)) as String? ?? '',
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'room': room,
      'time': time,
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
