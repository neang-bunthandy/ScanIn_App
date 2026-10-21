import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';

/// MockData ត្រូវបានរៀបចំឡើងតាមទម្រង់ទិន្នន័យ Relational Database (MySQL)
/// និង JSON Response ស្តង់ដាររបស់ Laravel REST API (snake_case + ID auto-increment)
class MockData {
  // ==========================================
  // ១. គណនីគំរូ (Current Logged-in Users)
  // ==========================================

  // គណនីសិស្សគំរូ (Sok Vibol)
  static const UserModel currentStudent = UserModel(
    id: 1,
    name: 'Sok Vibol',
    email: 'student@scanin.app',
    role: 'student',
    studentCode: 'STU001',
    department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
    phone: '012 345 678',
    avatarUrl: null,
  );

  // គណនីគ្រូ / បុគ្គលិកគំរូ
  static const UserModel currentLecturer = UserModel(
    id: 10,
    name: 'Mr. Dara',
    email: 'dara@scanin.app',
    role: 'lecturer',
    staffId: 'STF001',
    department: 'ដេប៉ាតឺម៉ង់ព័ត៌មានវិទ្យា',
    phone: '098 765 432',
    avatarUrl: null,
  );

  // ==========================================
  // ២. សង្ខេបវត្តមានប្រចាំខែ (Monthly Attendance Stats)
  // ==========================================
  static const int presentCount = 18;
  static const int lateCount = 2;
  static const int absentCount = 1;

  // ==========================================
  // ៣. បញ្ជីថ្នាក់រៀនគំរូ (Classes Table)
  // ==========================================
  static final List<ClassModel> sampleClasses = [
    const ClassModel(
      id: 101,
      lecturerId: 10,
      lecturerName: 'Mr. Dara',
      teacherEmail: 'dara.chan@scanin.app',
      teacherPhone: '098 765 432',
      description: 'សិក្សាអំពីការអភិវឌ្ឍកម្មវិធីទូរស័ព្ទជាមួយ Flutter & Dart, Widget Tree, State Management, Navigation និងការភ្ជាប់ REST API ជាមួយ Laravel Backend។',
      subjectName: 'Mobile Development',
      subjectCode: 'CS301',
      room: 'Lab 3 (អគារ A)',
      dayOfWeek: 'ចន្ទ',
      time: '08:00 - 10:30',
      semester: 'ឆមាសទី ១',
      academicYear: '2026-2027',
      studentCount: 35,
      completedSessions: 7,
      totalSessions: 15,
      isQrActive: true,
      qrToken: 'SCANIN-TOKEN-CS301-2026',
    ),
    const ClassModel(
      id: 102,
      lecturerId: 11,
      lecturerName: 'Ms. Sreyleak',
      teacherEmail: 'sreyleak.ms@scanin.app',
      teacherPhone: '012 888 999',
      description: 'សិក្សាអំពីមូលដ្ឋានគ្រឹះនៃប្រព័ន្ធទិន្នន័យ Relational Database Management System (RDBMS), SQL Queries, Normalization (1NF, 2NF, 3NF), Indexing, Transactions និងការរចនា ER Diagram។',
      subjectName: 'Database Systems',
      subjectCode: 'CS302',
      room: 'បន្ទប់ A204 (អគារ B)',
      dayOfWeek: 'អង្គារ',
      time: '13:00 - 15:30',
      semester: 'ឆមាសទី ១',
      academicYear: '2026-2027',
      studentCount: 30,
      completedSessions: 6,
      totalSessions: 15,
      isQrActive: false,
    ),
  ];

  // ==========================================
  // ៤. បញ្ជីសិស្សក្នុងថ្នាក់ (Class Student Roster)
  // ==========================================
  static final List<UserModel> enrolledStudents = [
    const UserModel(
      id: 1,
      name: 'សុខ វិបុល',
      email: 'student@scanin.app',
      role: 'student',
      studentCode: 'STU001',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 345 678',
    ),
    const UserModel(
      id: 2,
      name: 'កែវ ចិន្តា',
      email: 'chinda.keo@scanin.app',
      role: 'student',
      studentCode: 'STU002',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 002',
    ),
    const UserModel(
      id: 3,
      name: 'ឡុង វិសាល',
      email: 'visal.long@scanin.app',
      role: 'student',
      studentCode: 'STU003',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 003',
    ),
    const UserModel(
      id: 4,
      name: 'ម៉ៅ ស្រីពៅ',
      email: 'sreypov.mao@scanin.app',
      role: 'student',
      studentCode: 'STU004',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 004',
    ),
    const UserModel(
      id: 5,
      name: 'សេង ពិសិដ្ឋ',
      email: 'piseth.seng@scanin.app',
      role: 'student',
      studentCode: 'STU005',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 005',
    ),
    const UserModel(
      id: 6,
      name: 'អ៊ុំ រតនា',
      email: 'rothana.um@scanin.app',
      role: 'student',
      studentCode: 'STU006',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 006',
    ),
    const UserModel(
      id: 7,
      name: 'ហេង គឹមសួរ',
      email: 'kimsour.heng@scanin.app',
      role: 'student',
      studentCode: 'STU007',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 007',
    ),
    const UserModel(
      id: 8,
      name: 'ជា សុភ័ក្រ',
      email: 'sopheak.chea@scanin.app',
      role: 'student',
      studentCode: 'STU008',
      department: 'វិទ្យាសាស្ត្រកុំព្យូទ័រ',
      phone: '012 111 008',
    ),
  ];

  // ==========================================
  // ៥. កំណត់ត្រាវត្តមានគំរូ (Attendances Table)
  // ==========================================
  static final List<AttendanceModel> sampleAttendances = [
    AttendanceModel(
      id: 1001,
      classId: 101,
      studentId: 1,
      studentName: 'Sok Vibol',
      studentCode: 'STU001',
      status: 'present',
      scannedAt: DateTime(2026, 10, 15, 8, 5),
      date: '2026-10-15',
      note: 'Mobile Development (វត្តមាន)',
    ),
    AttendanceModel(
      id: 1002,
      classId: 102,
      studentId: 1,
      studentName: 'Sok Vibol',
      studentCode: 'STU001',
      status: 'late',
      scannedAt: DateTime(2026, 10, 14, 13, 18),
      date: '2026-10-14',
      note: 'Database Systems (យឺត 18 នាទី)',
    ),
    const AttendanceModel(
      id: 1003,
      classId: 101,
      studentId: 1,
      studentName: 'Sok Vibol',
      studentCode: 'STU001',
      status: 'absent',
      scannedAt: null,
      date: '2026-10-10',
      note: 'Mobile Development (អវត្តមាន)',
    ),
  ];

  // ==========================================
  // ៦. មុខងារទាញទិន្នន័យដូច Laravel Controller
  // ==========================================
  static ClassModel getClassById(int classId) {
    return sampleClasses.firstWhere(
      (c) => c.id == classId,
      orElse: () => sampleClasses.first,
    );
  }

  static List<ClassModel> getClassesForStudent(int studentId) {
    return sampleClasses;
  }

  static List<ClassModel> getClassesForLecturer(int lecturerId) {
    return sampleClasses.where((c) => c.lecturerId == lecturerId).toList();
  }

  static List<AttendanceModel> getAttendanceForClass(int classId) {
    return sampleAttendances.where((a) => a.classId == classId).toList();
  }

  static List<AttendanceModel> getAttendanceForStudent(int studentId) {
    return sampleAttendances.where((a) => a.studentId == studentId).toList();
  }

  static List<UserModel> getStudentsForClass(int classId) {
    return enrolledStudents;
  }

  static Map<String, dynamic> laravelEnvelope({
    required bool success,
    required String message,
    dynamic data,
  }) {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
