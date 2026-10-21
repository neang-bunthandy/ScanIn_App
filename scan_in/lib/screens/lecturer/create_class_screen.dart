import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
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
                  ? 'បានកែប្រែថ្នាក់ ${_subjectNameController.text.trim()} ជោគជ័យ'
                  : 'បានបង្កើតថ្នាក់ ${_subjectNameController.text.trim()} ជោគជ័យ',
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialClass != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'កែប្រែថ្នាក់រៀន' : 'បង្កើតថ្នាក់រៀនថ្មី',
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ព័ត៌មានមុខវិជ្ជា និងបន្ទប់សិក្សា',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'បំពេញទិន្នន័យដើម្បីបង្កើតកាលវិភាគ និងកូដ QR សម្រាប់និស្សិត',
                            style: TextStyle(
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
              _buildLabel('ឈ្មោះមុខវិជ្ជា (Subject Name) *'),
              TextFormField(
                controller: _subjectNameController,
                decoration: _buildInputDecoration(
                  hint: 'ឧ. Mobile Application Development',
                  icon: Icons.menu_book_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'សូមបញ្ចូលឈ្មោះមុខវិជ្ជា';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Subject Code Field
              _buildLabel('កូដមុខវិជ្ជា (Subject Code) *'),
              TextFormField(
                controller: _subjectCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: _buildInputDecoration(
                  hint: 'ឧ. CS301',
                  icon: Icons.tag_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'សូមបញ្ចូលកូដមុខវិជ្ជា (ឧ. CS301)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Room Field
              _buildLabel('បន្ទប់រៀន (Room / Lab) *'),
              TextFormField(
                controller: _roomController,
                decoration: _buildInputDecoration(
                  hint: 'ឧ. Lab 3 (អគារ A) ឬ B204',
                  icon: Icons.room_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'សូមបញ្ចូលបន្ទប់រៀន';
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
                        _buildLabel('ថ្ងៃបង្រៀន *'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDay,
                          decoration: _buildInputDecoration(
                            hint: 'ថ្ងៃ',
                            icon: Icons.calendar_today_rounded,
                          ),
                          items: _days
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
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
                        _buildLabel('ម៉ោងរៀន *'),
                        TextFormField(
                          controller: _timeController,
                          decoration: _buildInputDecoration(
                            hint: '08:00 - 10:30',
                            icon: Icons.access_time_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'សូមបញ្ចូលម៉ោង';
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
                        _buildLabel('ឆមាសសិក្សា'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSemester,
                          decoration: _buildInputDecoration(
                            hint: 'ឆមាស',
                            icon: Icons.timeline_rounded,
                          ),
                          items: _semesters
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
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
                        _buildLabel('ចំនួនសិស្ស'),
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
              _buildLabel('ការពិពណ៌នាមុខវិជ្ជា (Description)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hint: 'សេចក្តីសង្ខេបអំពីគោលបំណង និងខ្លឹមសារមេរៀន...',
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
                    isEdit ? 'រក្សាទុកការផ្លាស់ប្តូរ' : 'បង្កើតថ្នាក់រៀន',
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
