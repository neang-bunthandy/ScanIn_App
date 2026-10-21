import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_language.dart';
import '../../models/class_model.dart';
import '../../data/mock_data.dart';

/// អេក្រង់បង្ហាញ QR Code កម្រិតពេញអេក្រង់ (Projector / TV Mode)
/// សម្រាប់លោកគ្រូ អ្នកគ្រូ បញ្ចាំងលើស្លាយ ឬកញ្ចក់ទូរទស្សន៍ក្នុងបន្ទប់រៀន
class ShowQrScreen extends StatefulWidget {
  final ClassModel classModel;

  const ShowQrScreen({super.key, required this.classModel});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  late ClassModel _class;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  bool _isQrActive = true;
  late int _scannedCount;
  late String _currentToken;

  @override
  void initState() {
    super.initState();
    _class = widget.classModel;
    _remainingSeconds = 300; // 5 នាទី
    _scannedCount = (_class.studentCount * 0.75).round();
    _currentToken = _class.qrToken ?? 'SCANIN-${_class.subjectCode}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0 && _isQrActive) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds <= 0) {
        _regenerateQr();
      }
    });
  }

  void _regenerateQr() {
    setState(() {
      _remainingSeconds = 300;
      _currentToken = 'SCANIN-${_class.subjectCode}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLanguage.tr('បានបង្កើតកូដ QR ថ្មីដោយជោគជ័យ', 'Regenerated new QR code successfully')),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleQrActive() {
    setState(() {
      _isQrActive = !_isQrActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isQrActive
            ? AppLanguage.tr('បានបើកដំណើរការ QR ឡើងវិញ', 'Resumed QR code')
            : AppLanguage.tr('បានផ្អាកដំណើរការ QR', 'Paused QR code')),
        backgroundColor: _isQrActive ? AppColors.success : AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final students = MockData.getStudentsForClass(_class.id);
    final progress = _scannedCount / (_class.studentCount > 0 ? _class.studentCount : 1);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark projector background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _class.subjectName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_class.room} · ${_class.dayOfWeek} ${_class.time}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isQrActive ? AppLanguage.tr('ផ្អាក QR', 'Pause QR') : AppLanguage.tr('បើក QR', 'Resume QR'),
            icon: Icon(
              _isQrActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
              color: _isQrActive ? Colors.amber : Colors.greenAccent,
              size: 26,
            ),
            onPressed: _toggleQrActive,
          ),
          IconButton(
            tooltip: AppLanguage.tr('បង្កើត QR ថ្មី', 'Regenerate QR'),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
            onPressed: _regenerateQr,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _isQrActive
                      ? const Color(0xFF16A34A).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isQrActive ? const Color(0xFF4ADE80) : Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: _isQrActive ? const Color(0xFF4ADE80) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isQrActive
                          ? AppLanguage.tr('QR កំពុងផ្សាយសម្រាប់ការស្កេន', 'QR is active for scanning')
                          : AppLanguage.tr('QR ត្រូវបានផ្អាកបណ្តោះអាសន្ន', 'QR is temporarily paused'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isQrActive ? const Color(0xFF4ADE80) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main QR Container (White card for high contrast)
              Center(
                child: Container(
                  width: 310,
                  height: 310,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated QR Pattern Grid
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQrCorner(),
                              _buildQrCorner(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQrDot(),
                              _buildQrDot(),
                              _buildQrDot(),
                              _buildQrDot(),
                              _buildQrDot(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQrDot(),
                              _buildQrDot(),
                              _buildQrDot(),
                              _buildQrDot(),
                              _buildQrDot(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQrCorner(),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Center Logo / Badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Paused Overlay if paused
                      if (!_isQrActive)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pause_circle_filled_rounded, size: 54, color: Colors.amber),
                                const SizedBox(height: 8),
                                Text(
                                  AppLanguage.tr('បានផ្អាកការស្កេន', 'Scanning is paused'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Timer & Token Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${AppLanguage.tr('នៅសល់៖ ', 'Remaining: ')}${_formatTimer(_remainingSeconds)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(width: 1, height: 16, color: Colors.white24),
                    const SizedBox(width: 14),
                    Text(
                      _currentToken,
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Live Attendance Progress Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_alt_rounded, color: Colors.greenAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLanguage.tr('និស្សិតបានកត់វត្តមានផ្ទាល់', 'Live Checked-in Students'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$_scannedCount / ${_class.studentCount} ${AppLanguage.tr('នាក់', 'students')}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLanguage.tr('វត្តមាន៖ ', 'Present: ')}${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${AppLanguage.tr('អវត្តមាន៖ ', 'Absent: ')}${_class.studentCount - _scannedCount} ${AppLanguage.tr('នាក់', 'students')}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Scanned Students Preview
              if (students.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${AppLanguage.tr('និស្សិតទើបបានស្កេនថ្មីៗ', 'Recently Scanned Students')} (${students.take(5).length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.take(4).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = students[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              s.name.substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  s.studentCode ?? 'STU000',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded, color: Color(0xFF4ADE80), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  AppLanguage.tr('បានស្កេន', 'Checked-in'),
                                  style: const TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCorner() {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textPrimary, width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildQrDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
