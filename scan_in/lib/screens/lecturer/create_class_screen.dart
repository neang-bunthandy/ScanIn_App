import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../models/class_model.dart';
import '../../data/mock_data.dart';

/// អេក្រង់បង្កើត ឬកែប្រែថ្នាក់រៀនថ្មីសម្រាប់គ្រូបង្រៀន
class CreateClassScreen extends StatefulWidget {
  final ClassModel? initialClass;

  const CreateClassScreen({super.key, this.initialClass});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _subjectNameController;
  late TextEditingController _subjectCodeController;
  late TextEditingController _roomController;
  late TextEditingController _timeController;
  late TextEditingController _studentCountController;
  late TextEditingController _descriptionController;

  String _selectedDay = 'ចន្ទ';
  String _selectedSemester = 'ឆមាសទី ១';
  String _academicYear = '2026-2027';
  int _totalSessions = 15;

  final List<String> _days = [
    'ចន្ទ',
    'អង្គារ',
    'ពុធ',
    'ព្រហស្បតិ៍',
    'សុក្រ',
    'សៅរ៍',
    'អាទិត្យ',
  ];

  final List<String> _semesters = [
    'ឆមាសទី ១',
    'ឆមាសទី ២',
    'វគ្គពិសេស (Summer)',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialClass;
    _subjectNameController = TextEditingController(text: c?.subjectName ?? '');
    _subjectCodeController = TextEditingController(text: c?.subjectCode ?? '');
    _roomController = TextEditingController(text: c?.room ?? '');
    _timeController = TextEditingController(text: c?.time ?? '08:00 - 10:30');
    _studentCountController = TextEditingController(text: c != null ? '${c.studentCount}' : '30');
    _descriptionController = TextEditingController(text: c?.description ?? '');

    if (c != null) {
      if (_days.contains(c.dayOfWeek)) _selectedDay = c.dayOfWeek;
      if (_semesters.contains(c.semester)) _selectedSemester = c.semester;
      _academicYear = c.academicYear;
      _totalSessions = c.totalSessions;
    }
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _roomController.dispose();
    _timeController.dispose();
    _studentCountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveClass() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.initialClass != null;
    final lecturer = MockData.currentLecturer;

    final createdClass = ClassModel(
      id: widget.initialClass?.id ?? DateTime.now().millisecondsSinceEpoch,
      lecturerId: lecturer.id,
      lecturerName: lecturer.name,
      teacherEmail: lecturer.email,
      teacherPhone: lecturer.phone,
      subjectName: _subjectNameController.text.trim(),
      subjectCode: _subjectCodeController.text.trim().toUpperCase(),
      room: _roomController.text.trim(),
      dayOfWeek: _selectedDay,
      time: _timeController.text.trim(),
      semester: _selectedSemester,
      academicYear: _academicYear,
      studentCount: int.tryParse(_studentCountController.text.trim()) ?? 30,
      completedSessions: widget.initialClass?.completedSessions ?? 0,
      totalSessions: _totalSessions,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isQrActive: widget.initialClass?.isQrActive ?? false,
      qrToken: widget.initialClass?.qrToken ?? 'SCANIN-${_subjectCodeController.text.trim().toUpperCase()}-2026',
    );

    Navigator.pop(context, createdClass);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              isEdit
                  ? AppLanguage.tr('បានកែប្រែថ្នាក់ ${_subjectNameController.text.trim()} ជោគជ័យ', 'Successfully updated ${_subjectNameController.text.trim()}')
                  : AppLanguage.tr('បានបង្កើតថ្នាក់ ${_subjectNameController.text.trim()} ជោគជ័យ', 'Successfully created ${_subjectNameController.text.trim()}'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDay(String d) {
    switch (d) {
      case 'ចន្ទ':
        return AppLanguage.tr('ចន្ទ', 'Monday');
      case 'អង្គារ':
        return AppLanguage.tr('អង្គារ', 'Tuesday');
      case 'ពុធ':
        return AppLanguage.tr('ពុធ', 'Wednesday');
      case 'ព្រហស្បតិ៍':
        return AppLanguage.tr('ព្រហស្បតិ៍', 'Thursday');
      case 'សុក្រ':
        return AppLanguage.tr('សុក្រ', 'Friday');
      case 'សៅរ៍':
        return AppLanguage.tr('សៅរ៍', 'Saturday');
      case 'អាទិត្យ':
        return AppLanguage.tr('អាទិត្យ', 'Sunday');
      default:
        return d;
    }
  }

  String _formatSemester(String s) {
    switch (s) {
      case 'ឆមាសទី ១':
        return AppLanguage.tr('ឆមាសទី ១', 'Semester 1');
      case 'ឆមាសទី ២':
        return AppLanguage.tr('ឆមាសទី ២', 'Semester 2');
      case 'វគ្គពិសេស (Summer)':
        return AppLanguage.tr('វគ្គពិសេស (Summer)', 'Summer Term');
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialClass != null;

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLanguage,
      builder: (context, currentLang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              isEdit
                  ? AppLanguage.tr('កែប្រែថ្នាក់រៀន', 'Edit Class')
                  : AppLanguage.tr('បង្កើតថ្នាក់រៀនថ្មី', 'Create New Class'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLanguage.tr('ព័ត៌មានមុខវិជ្ជា និងបន្ទប់សិក្សា', 'Course & Classroom Information'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLanguage.tr('បំពេញទិន្នន័យដើម្បីបង្កើតកាលវិភាគ និងកូដ QR សម្រាប់និស្សិត', 'Fill in the information to schedule and generate QR code for students'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subject Name Field
                  _buildLabel(AppLanguage.tr('ឈ្មោះមុខវិជ្ជា (Subject Name) *', 'Subject Name *')),
                  TextFormField(
                    controller: _subjectNameController,
                    decoration: _buildInputDecoration(
                      hint: AppLanguage.tr('ឧ. Mobile Application Development', 'e.g. Mobile Application Development'),
                      icon: Icons.menu_book_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppLanguage.tr('សូមបញ្ចូលឈ្មោះមុខវិជ្ជា', 'Please enter subject name');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Subject Code Field
                  _buildLabel(AppLanguage.tr('កូដមុខវិជ្ជា (Subject Code) *', 'Subject Code *')),
                  TextFormField(
                    controller: _subjectCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _buildInputDecoration(
                      hint: AppLanguage.tr('ឧ. CS301', 'e.g. CS301'),
                      icon: Icons.tag_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppLanguage.tr('សូមបញ្ចូលកូដមុខវិជ្ជា (ឧ. CS301)', 'Please enter subject code (e.g. CS301)');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Room Field
                  _buildLabel(AppLanguage.tr('បន្ទប់រៀន (Room / Lab) *', 'Room / Lab *')),
                  TextFormField(
                    controller: _roomController,
                    decoration: _buildInputDecoration(
                      hint: AppLanguage.tr('ឧ. Lab 3 (អគារ A) ឬ B204', 'e.g. Lab 3 (Building A) or B204'),
                      icon: Icons.room_rounded,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppLanguage.tr('សូមបញ្ចូលបន្ទប់រៀន', 'Please enter room');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Day of Week & Time Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(AppLanguage.tr('ថ្ងៃបង្រៀន *', 'Day *')),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDay,
                              decoration: _buildInputDecoration(
                                hint: AppLanguage.tr('ថ្ងៃ', 'Day'),
                                icon: Icons.calendar_today_rounded,
                              ),
                              items: _days
                                  .map((d) => DropdownMenuItem(value: d, child: Text(_formatDay(d))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDay = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(AppLanguage.tr('ម៉ោងរៀន *', 'Time *')),
                            TextFormField(
                              controller: _timeController,
                              decoration: _buildInputDecoration(
                                hint: '08:00 - 10:30',
                                icon: Icons.access_time_rounded,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return AppLanguage.tr('សូមបញ្ចូលម៉ោង', 'Please enter time');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Semester & Student Count Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(AppLanguage.tr('ឆមាសសិក្សា', 'Semester')),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedSemester,
                              decoration: _buildInputDecoration(
                                hint: AppLanguage.tr('ឆមាស', 'Semester'),
                                icon: Icons.timeline_rounded,
                              ),
                              items: _semesters
                                  .map((s) => DropdownMenuItem(value: s, child: Text(_formatSemester(s), style: const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSemester = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(AppLanguage.tr('ចំនួនសិស្ស', 'Student Count')),
                            TextFormField(
                              controller: _studentCountController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                hint: '30',
                                icon: Icons.people_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  _buildLabel(AppLanguage.tr('ការពិពណ៌នាមុខវិជ្ជា (Description)', 'Course Description')),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      hint: AppLanguage.tr('សេចក្តីសង្ខេបអំពីគោលបំណង និងខ្លឹមសារមេរៀន...', 'Summary of course objectives and outline...'),
                      icon: Icons.notes_rounded,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saveClass,
                      icon: Icon(isEdit ? Icons.save_rounded : Icons.add_circle_outline_rounded, color: Colors.white),
                      label: Text(
                        isEdit
                            ? AppLanguage.tr('រក្សាទុកការផ្លាស់ប្តូរ', 'Save Changes')
                            : AppLanguage.tr('បង្កើតថ្នាក់រៀន', 'Create Class'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
