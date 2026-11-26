// Sub-Admin account management screen (Master Admin only).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_language.dart';
import '../core/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/sub_admin_service.dart';
import '../widgets/editable_combo_field.dart';
import 'admin_scaffold.dart';

class AdminSubAdminsScreen extends StatefulWidget {
  const AdminSubAdminsScreen({super.key});

  @override
  State<AdminSubAdminsScreen> createState() => _AdminSubAdminsScreenState();
}

class _AdminSubAdminsScreenState extends State<AdminSubAdminsScreen> {
  final ScrollController _horizontalScrollCtrl = ScrollController();
  List<Map<String, dynamic>> _subAdmins = [];
  UserModel? _currentUser;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.cachedUser;
    _loadData();
  }

  @override
  void dispose() {
    _horizontalScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getCurrentUser();
    final list = await SubAdminService.getSubAdmins();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _subAdmins = list;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredSubAdmins {
    if (_searchQuery.trim().isEmpty) return _subAdmins;
    final q = _searchQuery.trim().toLowerCase();
    return _subAdmins.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final latin = (s['latin_name'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      final phone = (s['phone'] ?? '').toString().toLowerCase();
      final dept = (s['department'] ?? '').toString().toLowerCase();
      return name.contains(q) || latin.contains(q) || email.contains(q) || phone.contains(q) || dept.contains(q);
    }).toList();
  }

  Future<void> _openCreateSubAdminDialog() async {
    final nameCtrl = TextEditingController();
    final latinNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'ការិយាល័យសិក្សា (Academic Affairs)');
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscurePass = true;
    bool isSaving = false;
    String? errorMsg;

    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
            final textCol = isDark ? Colors.white : AppColors.textPrimary;

            Future<void> handleSubmit() async {
              errorMsg = null;
              if (!formKey.currentState!.validate()) return;

              setDlgState(() => isSaving = true);

              final res = await SubAdminService.createSubAdmin(
                name: nameCtrl.text.trim(),
                latinName: latinNameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passCtrl.text,
                department: deptCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );

              if (res['success'] == true) {
                if (mounted) Navigator.pop(dialogCtx, true);
              } else {
                setDlgState(() {
                  isSaving = false;
                  errorMsg = res['message']?.toString() ?? 'Failed to create sub-admin';
                });
              }
            }

            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLanguage.tr('បង្កើតគណនី Sub-Admin ថ្មី', 'Create New Sub-Admin'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMsg!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរខ្មែរ (Name)', 'Khmer Name'),
                            hintText: 'ឧ. ស៊ុន ចាន់ដា',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលឈ្មោះ', 'Name is required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: latinNameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរឡាតាំង (Latin Name)', 'Latin Name'),
                            hintText: 'ឧ. Sun Chanda',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អ៊ីមែល (Email)', 'Email'),
                            hintText: 'chanda@school.edu.kh',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលអ៊ីមែល', 'Email is required');
                            }
                            if (!val.contains('@')) {
                              return AppLanguage.tr('ទម្រង់អ៊ីមែលមិនត្រឹមត្រូវ', 'Invalid email format');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: passCtrl,
                          obscureText: obscurePass,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ពាក្យសម្ងាត់ (Password)', 'Password'),
                            hintText: 'យ៉ាងតិច ៦ ខ្ទង់',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            suffixIcon: IconButton(
                              icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                              onPressed: () => setDlgState(() => obscurePass = !obscurePass),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលពាក្យសម្ងាត់', 'Password is required');
                            }
                            if (val.trim().length < 6) {
                              return AppLanguage.tr('យ៉ាងតិច ៦ ខ្ទង់', 'Min 6 characters');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        EditableComboField(
                          controller: deptCtrl,
                          labelText: AppLanguage.tr('ការិយាល័យ / ដេប៉ាតឺម៉ង់ (Department)', 'Department / Office'),
                          hintText: 'ឧ. ការិយាល័យសិក្សា',
                          suggestions: const [
                            'ការិយាល័យសិក្សា (Academic Affairs)',
                            'ការិយាល័យរដ្ឋបាល (Administration Office)',
                            'ព័ត៌មានវិទ្យា (IT)',
                            'ទូទៅ (General)',
                          ],
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: phoneCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('លេខទូរស័ព្ទ (Phone)', 'Phone Number'),
                            hintText: '012 345 678',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx, false),
                  child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving ? null : handleSubmit,
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppLanguage.tr('បង្កើត', 'Create')),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr('បានបង្កើតគណនី Sub-Admin ដោយជោគជ័យ!', 'Sub-Admin created successfully!')),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openEditSubAdminDialog(Map<String, dynamic> item) async {
    final id = item['id'] as int;
    final nameCtrl = TextEditingController(text: item['name'] ?? '');
    final latinNameCtrl = TextEditingController(text: item['latin_name'] ?? '');
    final emailCtrl = TextEditingController(text: item['email'] ?? '');
    final passCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: item['department'] ?? 'ការិយាល័យសិក្សា (Academic Affairs)');
    final phoneCtrl = TextEditingController(text: item['phone'] ?? '');
    String status = (item['status'] ?? 'active').toString().toLowerCase();
    final formKey = GlobalKey<FormState>();

    bool obscurePass = true;
    bool isSaving = false;
    String? errorMsg;

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
            final textCol = isDark ? Colors.white : AppColors.textPrimary;

            Future<void> handleSubmit() async {
              errorMsg = null;
              if (!formKey.currentState!.validate()) return;

              setDlgState(() => isSaving = true);

              final res = await SubAdminService.updateSubAdmin(
                id: id,
                name: nameCtrl.text.trim(),
                latinName: latinNameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passCtrl.text.isNotEmpty ? passCtrl.text : null,
                department: deptCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                status: status,
              );

              if (res['success'] == true) {
                if (mounted) Navigator.pop(dialogCtx, true);
              } else {
                setDlgState(() {
                  isSaving = false;
                  errorMsg = res['message']?.toString() ?? 'Failed to update sub-admin';
                });
              }
            }

            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLanguage.tr('កែសម្រួលគណនី Sub-Admin', 'Edit Sub-Admin Details'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMsg!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរខ្មែរ', 'Khmer Name'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលឈ្មោះ', 'Name is required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: latinNameCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ឈ្មោះជាអក្សរឡាតាំង', 'Latin Name'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('អ៊ីមែល (Email)', 'Email'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppLanguage.tr('សូមបញ្ចូលអ៊ីមែល', 'Email is required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: passCtrl,
                          obscureText: obscurePass,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ពាក្យសម្ងាត់ថ្មី (ទុកទទេបើមិនចង់ប្តូរ)', 'New Password (leave empty to keep)'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            suffixIcon: IconButton(
                              icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                              onPressed: () => setDlgState(() => obscurePass = !obscurePass),
                            ),
                          ),
                          validator: (val) {
                            if (val != null && val.isNotEmpty && val.length < 6) {
                              return AppLanguage.tr('ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ ខ្ទង់', 'Min 6 characters');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        EditableComboField(
                          controller: deptCtrl,
                          labelText: AppLanguage.tr('ការិយាល័យ / ដេប៉ាតឺម៉ង់ (Department)', 'Department / Office'),
                          hintText: 'ឧ. ការិយាល័យសិក្សា',
                          suggestions: const [
                            'ការិយាល័យសិក្សា (Academic Affairs)',
                            'ការិយាល័យរដ្ឋបាល (Administration Office)',
                            'ព័ត៌មានវិទ្យា (IT)',
                            'ទូទៅ (General)',
                          ],
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: phoneCtrl,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('លេខទូរស័ព្ទ (Phone)', 'Phone Number'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('ស្ថានភាព (Status)', 'Status'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('សកម្ម (Active)')),
                            DropdownMenuItem(value: 'inactive', child: Text('អសកម្ម (Inactive / ផ្អាក)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDlgState(() => status = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx, false),
                  child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving ? null : handleSubmit,
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppLanguage.tr('រក្សាទុក', 'Save Changes')),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.tr('បានកែប្រែព័ត៌មាន Sub-Admin ដោយជោគជ័យ!', 'Sub-Admin updated successfully!')),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteSubAdmin(Map<String, dynamic> item) async {
    final id = item['id'] as int;
    final name = item['name'] ?? 'Sub-Admin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLanguage.tr('លុបគណនី Sub-Admin?', 'Delete Sub-Admin?')),
        content: Text(
          AppLanguage.tr(
            'តើអ្នកពិតជាចង់លុបគណនី "$name" នេះឬទេ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានឡើយ។',
            'Are you sure you want to delete "$name"? This action cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLanguage.tr('បោះបង់', 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLanguage.tr('លុប', 'Delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await SubAdminService.deleteSubAdmin(id);
      if (res['success'] == true) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Deleted successfully'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to delete'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final isMasterAdmin = _currentUser?.isMasterAdmin ?? false;
    if (!isMasterAdmin && !_isLoading) {
      return AdminScaffold(
        title: AppLanguage.tr('គ្រប់គ្រង Sub-Admin', 'Sub-Admin Management'),
        currentRoute: AppRoutes.subAdmins,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gpp_bad_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                AppLanguage.tr(
                  'មានតែ Master Admin ប៉ុណ្ណោះដែលអាចចូលមើលផ្ទាំងនេះបាន!',
                  'Access Denied: Master Admin Only!',
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            ],
          ),
        ),
      );
    }

    final totalCount = _subAdmins.length;
    final activeCount = _subAdmins.where((s) => (s['status'] ?? 'active') == 'active').length;
    final filtered = _filteredSubAdmins;

    return AdminScaffold(
      title: AppLanguage.tr('ការគ្រប់គ្រង Sub-Admin (ការិយាល័យសិក្សា)', 'Sub-Admin Management (Academic Affairs)'),
      currentRoute: AppRoutes.subAdmins,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLanguage.tr('បុគ្គលិកការិយាល័យសិក្សា (Sub-Admins)', 'Academic Affairs Staff (Sub-Admins)'),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCol),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLanguage.tr(
                            'គ្រប់គ្រងគណនី Sub-Admin សម្រាប់ជួយការងារសិស្ស ថ្នាក់រៀន និងកាលវិភាគ',
                            'Manage Sub-Admin staff accounts for academic operations',
                          ),
                          style: TextStyle(fontSize: 13, color: subTextCol),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _openCreateSubAdminDialog,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: Text(
                      AppLanguage.tr('+ បង្កើត Sub-Admin ថ្មី', '+ Add Sub-Admin'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _buildMetricCard(
                    title: AppLanguage.tr('Sub-Admin សរុប', 'Total Sub-Admins'),
                    value: '$totalCount',
                    icon: Icons.shield_outlined,
                    color: AppColors.primary,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textCol: textCol,
                    subTextCol: subTextCol,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: AppLanguage.tr('កំពុងសកម្ម', 'Active Staff'),
                    value: '$activeCount',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF10B981),
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textCol: textCol,
                    subTextCol: subTextCol,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricCard(
                    title: AppLanguage.tr('អសកម្ម / ផ្អាក', 'Inactive'),
                    value: '${totalCount - activeCount}',
                    icon: Icons.pause_circle_outline,
                    color: const Color(0xFFF59E0B),
                    cardBg: cardBg,
                    borderCol: borderCol,
                    textCol: textCol,
                    subTextCol: subTextCol,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppLanguage.tr(
                            'ស្វែងរកតាម ឈ្មោះ, អ៊ីមែល, ឬដេប៉ាតឺម៉ង់...',
                            'Search by name, email, or department...',
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: AppLanguage.tr('ទាញយកឡើងវិញ', 'Refresh'),
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _loadData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.shield_outlined, size: 48, color: subTextCol),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLanguage.tr('មិនមានទិន្នន័យ Sub-Admin ឡើយ', 'No Sub-Admin accounts found'),
                                    style: TextStyle(fontSize: 15, color: subTextCol),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, tableConstraints) {
                              return ScrollConfiguration(
                                behavior: const MaterialScrollBehavior().copyWith(
                                  dragDevices: {
                                    PointerDeviceKind.mouse,
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.trackpad,
                                  },
                                ),
                                child: Scrollbar(
                                  controller: _horizontalScrollCtrl,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScrollCtrl,
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: tableConstraints.maxWidth),
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(
                                          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                        ),
                                  columns: [
                                    DataColumn(label: Text(AppLanguage.tr('ឈ្មោះខ្មែរ', 'Khmer Name'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                    DataColumn(label: Text(AppLanguage.tr('ឈ្មោះឡាតាំង', 'Latin Name'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                    DataColumn(label: Text(AppLanguage.tr('អ៊ីមែល', 'Email'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                    DataColumn(label: Text(AppLanguage.tr('ការិយាល័យ / ដេប៉ាតឺម៉ង់', 'Department'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                    DataColumn(label: Text(AppLanguage.tr('លេខទូរស័ព្ទ', 'Phone'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                    DataColumn(label: Text(AppLanguage.tr('ស្ថានភាព', 'Status'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                    DataColumn(label: Text(AppLanguage.tr('សកម្មភាព', 'Actions'), style: TextStyle(fontWeight: FontWeight.bold, color: textCol))),
                                  ],
                                  rows: filtered.map((s) {
                                    final isActive = (s['status'] ?? 'active') == 'active';
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(s['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: textCol))),
                                        DataCell(Text(s['latin_name'] ?? '-', style: TextStyle(color: subTextCol))),
                                        DataCell(Text(s['email'] ?? '-', style: TextStyle(color: textCol))),
                                        DataCell(Text(s['department'] ?? 'ការិយាល័យសិក្សា', style: TextStyle(color: subTextCol))),
                                        DataCell(Text(s['phone'] ?? '-', style: TextStyle(color: subTextCol))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                                  : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isActive ? 'សកម្ម (Active)' : 'អសកម្ម (Inactive)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: AppLanguage.tr('កែប្រែ', 'Edit'),
                                                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0284C7)),
                                                onPressed: () => _openEditSubAdminDialog(s),
                                              ),
                                              IconButton(
                                                tooltip: AppLanguage.tr('លុប', 'Delete'),
                                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                                onPressed: () => _handleDeleteSubAdmin(s),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: subTextCol, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCol)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
