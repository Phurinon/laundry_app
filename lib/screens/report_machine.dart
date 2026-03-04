import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/machine_report.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/report_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';

// ─────────────────────────────────────────────
// Report Form Screen  (submit a new report)
// ─────────────────────────────────────────────

class ReportMachineScreen extends ConsumerStatefulWidget {
  /// If a machine is pre-selected (e.g. from machine_info)
  final Machine? machine;

  const ReportMachineScreen({super.key, this.machine});

  @override
  ConsumerState<ReportMachineScreen> createState() =>
      _ReportMachineScreenState();
}

class _ReportMachineScreenState extends ConsumerState<ReportMachineScreen> {
  final _descController = TextEditingController();
  ReportType? _selectedReportType;
  Machine? _selectedMachine;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedMachine = widget.machine;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  // Map report type to Thai label + icon
  static const _reportTypeInfo = <ReportType, _CategoryMeta>{
    ReportType.forgotLaundry: _CategoryMeta(
      label: 'ลืมผ้าในเครื่อง',
      icon: Icons.checkroom_rounded,
      color: AppTheme.warning,
    ),
    ReportType.machineBroken: _CategoryMeta(
      label: 'เครื่องเสีย',
      icon: Icons.build_rounded,
      color: AppTheme.error,
    ),
    ReportType.usedWithoutBooking: _CategoryMeta(
      label: 'ใช้งานโดยไม่จอง',
      icon: Icons.no_accounts_rounded,
      color: Color(0xFF9C27B0),
    ),
    ReportType.other: _CategoryMeta(
      label: 'อื่นๆ',
      icon: Icons.more_horiz_rounded,
      color: AppTheme.neutral500,
    ),
  };

  Future<void> _submit() async {
    if (_selectedMachine == null) {
      _showSnack('กรุณาเลือกเครื่องที่ต้องการรายงาน', isError: true);
      return;
    }
    if (_selectedReportType == null) {
      _showSnack('กรุณาเลือกประเภทปัญหา', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final desc = _descController.text.trim();
      await ref
          .read(reportProvider)
          .submitReport(
            machineId: _selectedMachine!.id,
            reportType: _selectedReportType!,
            description: desc.isNotEmpty ? desc : null,
          );

      if (!mounted) return;
      _showSnack('ส่งรายงานเรียบร้อยแล้ว');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg, style: GoogleFonts.prompt(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'รายงานปัญหา',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.error,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Info ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.report_problem_rounded,
                      color: AppTheme.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'กรุณาระบุรายละเอียดปัญหาที่พบ\nเพื่อให้ทีมงานดำเนินการแก้ไขโดยเร็ว',
                      style: GoogleFonts.prompt(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Select Machine ──
            _sectionLabel('เครื่องที่ต้องการรายงาน'),
            const SizedBox(height: 10),
            _buildMachineSelector(),
            const SizedBox(height: 24),

            // ── Select Category ──
            _sectionLabel('ประเภทปัญหา'),
            const SizedBox(height: 10),
            _buildCategoryGrid(),
            const SizedBox(height: 24),

            // ── Description ──
            _sectionLabel('รายละเอียดเพิ่มเติม (ไม่บังคับ)'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _descController,
                maxLines: 5,
                style: GoogleFonts.prompt(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'อธิบายปัญหาที่พบ เช่น เครื่องไม่หมุน, น้ำไหลออกมาด้านหลัง...',
                  hintStyle: GoogleFonts.prompt(
                    fontSize: 13,
                    color: AppTheme.neutral400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.surface,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ส่งรายงาน',
                            style: GoogleFonts.prompt(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.prompt(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  // ── Machine Selector ──
  Widget _buildMachineSelector() {
    final machinesAsync = ref.watch(machineProvider);

    return machinesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
      data: (machines) {
        // If pre-selected, show as read-only chip
        if (widget.machine != null) {
          final m = widget.machine!;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  m.machineType == MachineType.washer
                      ? Icons.local_laundry_service_rounded
                      : Icons.dry_cleaning_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'เครื่อง ${m.machineNumber} (${m.machineType == MachineType.washer ? 'ซัก' : 'อบ'})',
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 22,
                ),
              ],
            ),
          );
        }

        // Otherwise, show a dropdown-like selector
        return GestureDetector(
          onTap: () => _showMachinePicker(machines),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedMachine != null
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : AppTheme.neutral200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedMachine != null
                      ? Icons.local_laundry_service_rounded
                      : Icons.add_circle_outline_rounded,
                  color: _selectedMachine != null
                      ? AppTheme.primary
                      : AppTheme.neutral400,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedMachine != null
                        ? 'เครื่อง ${_selectedMachine!.machineNumber} (${_selectedMachine!.machineType == MachineType.washer ? 'ซัก' : 'อบ'})'
                        : 'เลือกเครื่องที่ต้องการรายงาน',
                    style: GoogleFonts.prompt(
                      fontSize: 14,
                      fontWeight: _selectedMachine != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _selectedMachine != null
                          ? AppTheme.textPrimary
                          : AppTheme.neutral400,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.neutral400,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMachinePicker(List<Machine> machines) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'เลือกเครื่อง',
                style: GoogleFonts.prompt(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: machines.length,
                itemBuilder: (_, i) {
                  final m = machines[i];
                  final isSelected = _selectedMachine?.id == m.id;
                  return ListTile(
                    leading: Icon(
                      m.machineType == MachineType.washer
                          ? Icons.local_laundry_service_rounded
                          : Icons.dry_cleaning_rounded,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.neutral500,
                    ),
                    title: Text(
                      'เครื่อง ${m.machineNumber}',
                      style: GoogleFonts.prompt(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      m.machineType == MachineType.washer
                          ? 'เครื่องซักผ้า'
                          : 'เครื่องอบผ้า',
                      style: GoogleFonts.prompt(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.success,
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedMachine = m);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category Grid ──
  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ReportType.values.map((cat) {
        final meta = _reportTypeInfo[cat]!;
        final isSelected = _selectedReportType == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedReportType = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? meta.color.withValues(alpha: 0.12)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? meta.color.withValues(alpha: 0.5)
                    : AppTheme.neutral200,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: meta.color.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  meta.icon,
                  size: 18,
                  color: isSelected ? meta.color : AppTheme.neutral500,
                ),
                const SizedBox(width: 6),
                Text(
                  meta.label,
                  style: GoogleFonts.prompt(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? meta.color : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Helper class
class _CategoryMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryMeta({
    required this.label,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────
// My Reports Screen  (view submitted reports)
// ─────────────────────────────────────────────

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'รายงานของฉัน',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.error,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportMachineScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'เกิดข้อผิดพลาด: $e',
            style: GoogleFonts.prompt(color: AppTheme.error),
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (_, i) => _buildReportCard(context, reports[i]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ไม่มีรายงาน',
            style: GoogleFonts.prompt(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'คุณยังไม่ได้รายงานปัญหาใดๆ',
            style: GoogleFonts.prompt(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MachineReport report) {
    final statusInfo = _getStatusInfo(report.status);
    final catInfo = _getReportTypeInfo(report.reportType);
    final dateStr = _formatDate(report.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: machine + status
          Row(
            children: [
              Icon(catInfo.icon, color: catInfo.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  catInfo.label,
                  style: GoogleFonts.prompt(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusInfo.label,
                  style: GoogleFonts.prompt(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusInfo.color,
                  ),
                ),
              ),
            ],
          ),
          if (report.description != null && report.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Description
            Text(
              report.description!,
              style: GoogleFonts.prompt(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (report.resolvedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'แก้ไขเมื่อ ${_formatDate(report.resolvedAt!)}',
                  style: GoogleFonts.prompt(
                    fontSize: 11,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Date
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppTheme.neutral400,
              ),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: GoogleFonts.prompt(
                  fontSize: 11,
                  color: AppTheme.neutral400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static _StatusMeta _getStatusInfo(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return _StatusMeta(label: 'รอตรวจสอบ', color: AppTheme.warning);
      case ReportStatus.resolved:
        return _StatusMeta(label: 'แก้ไขแล้ว', color: AppTheme.success);
      case ReportStatus.dismissed:
        return _StatusMeta(label: 'ปฏิเสธ', color: AppTheme.error);
    }
  }

  static _CategoryMeta _getReportTypeInfo(ReportType type) {
    const map = <ReportType, _CategoryMeta>{
      ReportType.forgotLaundry: _CategoryMeta(
        label: 'ลืมผ้าในเครื่อง',
        icon: Icons.checkroom_rounded,
        color: AppTheme.warning,
      ),
      ReportType.machineBroken: _CategoryMeta(
        label: 'เครื่องเสีย',
        icon: Icons.build_rounded,
        color: AppTheme.error,
      ),
      ReportType.usedWithoutBooking: _CategoryMeta(
        label: 'ใช้งานโดยไม่จอง',
        icon: Icons.no_accounts_rounded,
        color: Color(0xFF9C27B0),
      ),
      ReportType.other: _CategoryMeta(
        label: 'อื่นๆ',
        icon: Icons.more_horiz_rounded,
        color: AppTheme.neutral500,
      ),
    };
    return map[type]!;
  }

  static String _formatDate(DateTime dt) {
    final thaiMonths = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${thaiMonths[dt.month]} ${dt.year + 543} $hour:$minute';
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta({required this.label, required this.color});
}
