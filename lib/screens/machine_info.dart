import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/providers/machine_signal_provider.dart';
import 'package:laundry_app/screens/components/machine_illustration.dart';
import 'package:laundry_app/screens/report_machine.dart';

class MachineInfoScreen extends ConsumerStatefulWidget {
  final Machine machine;

  const MachineInfoScreen({super.key, required this.machine});

  @override
  ConsumerState<MachineInfoScreen> createState() => _MachineInfoScreenState();
}

class _MachineInfoScreenState extends ConsumerState<MachineInfoScreen>
    with SingleTickerProviderStateMixin {
  bool _isBooking = false;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isWasher => widget.machine.machineType == MachineType.washer;
  Color get _machineColor => _isWasher ? AppTheme.primary : AppTheme.accent;
  String get _typeName => _isWasher ? 'เครื่องซักผ้า' : 'เครื่องอบผ้า';
  String get _duration => _isWasher ? '~40 นาที' : '~50 นาที';

  @override
  Widget build(BuildContext context) {
    final machine = widget.machine;
    final statusColor = _getStatusColor(machine.status);
    final signalState = ref.watch(machineSignalProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _machineColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReportMachineScreen(machine: widget.machine),
                    ),
                  );
                },
                icon: const Icon(Icons.flag_rounded),
                tooltip: 'รายงานปัญหา',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _machineColor,
                      _machineColor.withValues(alpha: 0.7),
                      _isWasher ? AppTheme.primaryDark : AppTheme.accentDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // Machine illustration with glow
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: MachineIllustration(
                          machineType: machine.machineType,
                          size: 110,
                          primaryColor: Colors.white,
                          secondaryColor: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Machine number
                      Text(
                        'เครื่อง ${machine.machineNumber}',
                        style: GoogleFonts.prompt(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Type label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _typeName,
                          style: GoogleFonts.prompt(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body Content ──
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    children: [
                      // ── Status Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getStatusIcon(machine.status),
                                color: statusColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'สถานะเครื่อง',
                                    style: GoogleFonts.prompt(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getStatusText(machine.status),
                                    style: GoogleFonts.prompt(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Animated dot
                            if (machine.status == MachineStatus.available)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Info List ──
                      _buildInfoTile(
                        icon: Icons.category_rounded,
                        label: 'ประเภท',
                        value: _isWasher ? 'ซักผ้า' : 'อบผ้า',
                        color: _machineColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.scale_rounded,
                        label: 'ขนาด',
                        value: '${machine.capacity} กก.',
                        color: AppTheme.success,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.payments_rounded,
                        label: 'ราคา',
                        value: '${machine.price} บาท',
                        color: AppTheme.warning,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.timer_outlined,
                        label: 'ระยะเวลา',
                        value: _duration,
                        color: AppTheme.accentDark,
                      ),

                      const SizedBox(height: 20),

                      // ── Simulation Card ──
                      _buildSimulationCard(signalState),

                      const SizedBox(height: 32),

                      // ── Booking Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: machine.status == MachineStatus.available
                                ? LinearGradient(
                                    colors: [
                                      _machineColor,
                                      _isWasher
                                          ? AppTheme.primaryDark
                                          : AppTheme.accentDark,
                                    ],
                                  )
                                : null,
                            color: machine.status != MachineStatus.available
                                ? AppTheme.neutral200
                                : null,
                            boxShadow: machine.status == MachineStatus.available
                                ? [
                                    BoxShadow(
                                      color: _machineColor.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed:
                                machine.status == MachineStatus.available &&
                                    !_isBooking
                                ? _handleBooking
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isBooking
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
                                      Icon(
                                        machine.status ==
                                                MachineStatus.available
                                            ? Icons.calendar_month_rounded
                                            : Icons.block_rounded,
                                        color:
                                            machine.status ==
                                                MachineStatus.available
                                            ? Colors.white
                                            : AppTheme.neutral400,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        machine.status ==
                                                MachineStatus.available
                                            ? 'จองคิวเลย'
                                            : _getStatusText(machine.status),
                                        style: GoogleFonts.prompt(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              machine.status ==
                                                  MachineStatus.available
                                              ? Colors.white
                                              : AppTheme.neutral400,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Simulation Card ──
  Widget _buildSimulationCard(MachineSignalState signalState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart_rounded, color: _machineColor),
                  const SizedBox(width: 8),
                  Text(
                    'จำลองการทำงาน',
                    style: GoogleFonts.prompt(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (signalState.status != MachineWorkStatus.idle)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _machineColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    signalState.status.name,
                    style: GoogleFonts.prompt(
                      fontSize: 12,
                      color: _machineColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutral200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.electrical_services_rounded, size: 20, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'กระแสไฟฟ้า',
                              style: GoogleFonts.prompt(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '${signalState.currentAmps.toStringAsFixed(2)} A',
                              style: GoogleFonts.prompt(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutral200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 20, color: AppTheme.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สถานะ',
                              style: GoogleFonts.prompt(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              signalState.status == MachineWorkStatus.idle ? '-' : 'กำลังทำงาน',
                              style: GoogleFonts.prompt(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: signalState.status == MachineWorkStatus.idle
                      ? () => ref.read(machineSignalProvider.notifier).startMockWashing()
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    'เริ่มจำลอง',
                    style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _machineColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.neutral200,
                    disabledForegroundColor: AppTheme.neutral400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: signalState.status != MachineWorkStatus.idle
                      ? () => ref.read(machineSignalProvider.notifier).resetWork()
                      : null,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    'รีเซ็ต',
                    style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(
                      color: signalState.status != MachineWorkStatus.idle
                          ? AppTheme.error
                          : AppTheme.neutral200,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info Tile (row item) ──
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.prompt(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking() async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(minutes: 5)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: AppTheme.surface,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null || !mounted) return;

    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถจองเวลาย้อนหลังได้',
            style: GoogleFonts.prompt(),
          ),
        ),
      );
      return;
    }

    // ── Check time conflict before confirming ──
    if (!mounted) return;
    setState(() => _isBooking = true);

    final durationMinutes = _isWasher ? 40 : 50;
    String? conflictTime;
    try {
      conflictTime = await ref
          .read(bookingProvider)
          .checkTimeConflict(
            machineId: widget.machine.id,
            startTime: selectedDateTime,
            durationMinutes: durationMinutes,
          );
    } catch (_) {
      // If check fails, let the booking proceed and rely on server-side validation
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }

    if (!mounted) return;

    if (conflictTime != null) {
      final endTime = selectedDateTime.add(Duration(minutes: durationMinutes));
      final requestedEnd =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.event_busy_rounded, color: AppTheme.error),
              const SizedBox(width: 10),
              Text(
                'ช่วงเวลาไม่ว่าง',
                style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.block_rounded,
                          color: AppTheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'มีคิวจองอยู่แล้ว: $conflictTime',
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'คุณเลือก: ${time.format(context)} - $requestedEnd',
                            style: GoogleFonts.prompt(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'กรุณาเลือกเวลาอื่นที่ไม่ซ้อนกับคิวที่มีอยู่',
                style: GoogleFonts.prompt(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _machineColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'เลือกเวลาใหม่',
                style: GoogleFonts.prompt(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: _machineColor),
            const SizedBox(width: 10),
            Text(
              'ยืนยันการจอง',
              style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _machineColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildDialogRow('เครื่อง', widget.machine.machineNumber),
                  const SizedBox(height: 8),
                  _buildDialogRow('เวลา', time.format(context)),
                  const SizedBox(height: 8),
                  _buildDialogRow('ราคา', '${widget.machine.price} บาท'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.prompt(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _machineColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'ยืนยัน',
              style: GoogleFonts.prompt(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isBooking = true);
    try {
      await ref
          .read(bookingProvider)
          .createBooking(
            machineId: widget.machine.id,
            machineNumber: widget.machine.machineNumber,
            startTime: selectedDateTime,
            durationMinutes: durationMinutes,
          );

      if (mounted) {
        // Force refresh providers so home screen updates immediately
        ref.invalidate(activeBookingsProvider);
        ref.invalidate(machineProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'จองคิวสำเร็จ!',
                  style: GoogleFonts.prompt(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาด: ${e.toString().replaceAll("Exception: ", "")}',
              style: GoogleFonts.prompt(),
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.prompt(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.prompt(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  IconData _getStatusIcon(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return Icons.check_circle_rounded;
      case MachineStatus.inUse:
        return Icons.play_circle_rounded;
      case MachineStatus.reserved:
        return Icons.schedule_rounded;
      case MachineStatus.maintenance:
        return Icons.build_circle_rounded;
      case MachineStatus.overdue:
        return Icons.warning_rounded;
    }
  }

  String _getStatusText(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return 'พร้อมใช้งาน';
      case MachineStatus.inUse:
        return 'กำลังทำงาน';
      case MachineStatus.reserved:
        return 'จองแล้ว';
      case MachineStatus.maintenance:
        return 'ซ่อมบำรุง';
      case MachineStatus.overdue:
        return 'ผ้าตกค้าง';
    }
  }

  Color _getStatusColor(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return AppTheme.success;
      case MachineStatus.inUse:
        return AppTheme.error;
      case MachineStatus.reserved:
        return AppTheme.warning;
      case MachineStatus.maintenance:
        return AppTheme.textSecondary;
      case MachineStatus.overdue:
        return AppTheme.accentDark;
    }
  }
}

extension on Machine {
  int get price => 20;
}
