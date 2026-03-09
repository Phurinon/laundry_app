import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/providers/machine_signal_provider.dart';
import 'package:laundry_app/screens/components/machine_illustration.dart';
import 'package:laundry_app/screens/report_machine.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen>
    with SingleTickerProviderStateMixin {
  late Booking _currentBooking;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
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

  bool _isTimeToCheckIn() {
    final now = DateTime.now();
    return now.isAfter(
      _currentBooking.startTime.subtract(const Duration(minutes: 5)),
    );
  }

  bool _isPastEndTime() {
    final now = DateTime.now();
    return now.isAfter(_currentBooking.endTime);
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.warning;
      case BookingStatus.checkedIn:
        return AppTheme.primary;
      case BookingStatus.inProgress:
        return const Color(0xFF5B9CF6);
      case BookingStatus.completed:
        return AppTheme.success;
      case BookingStatus.cancelled:
        return AppTheme.error;
      case BookingStatus.noShow:
        return AppTheme.neutral400;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'ถึงคิวของคุณแล้ว';
      case BookingStatus.checkedIn:
        return 'คิวของคุณ (เช็คอินแล้ว)';
      case BookingStatus.inProgress:
        return 'ผ้าคุณกำลังซักอยู่';
      case BookingStatus.completed:
        return 'เสร็จสิ้น';
      case BookingStatus.cancelled:
        return 'ยกเลิกแล้ว';
      case BookingStatus.noShow:
        return 'ไม่มาใช้งาน';
    }
  }

  @override
  Widget build(BuildContext context) {
    final myBookingsAsync = ref.watch(myBookingsProvider);
    if (myBookingsAsync.hasValue) {
      final updated = myBookingsAsync.value!.firstWhere(
        (b) => b.id == _currentBooking.id,
        orElse: () => _currentBooking,
      );
      if (updated.status != _currentBooking.status) {
        Future.microtask(() {
          if (mounted) setState(() => _currentBooking = updated);
        });
      }
    }

    final machinesAsync = ref.watch(machineProvider);
    Machine? machine;
    if (machinesAsync.hasValue) {
      try {
        machine = machinesAsync.value!.firstWhere(
          (m) => m.id == _currentBooking.machineId,
        );
      } catch (_) {
        machine = null;
      }
    }

    final rawSignalState = ref.watch(machineSignalProvider);
    final signalState = rawSignalState.machineId == _currentBooking.machineId
        ? rawSignalState
        : MachineSignalState(status: MachineWorkStatus.idle);

    final isWasher = machine?.machineType == MachineType.washer;
    final themeColor = isWasher ? AppTheme.primary : AppTheme.accent;

    Color statusColor;
    String statusText;

    if (signalState.status != MachineWorkStatus.idle) {
      if (signalState.status == MachineWorkStatus.finished) {
        statusText = 'ซักผ้าเสร็จแล้ว!';
        statusColor = AppTheme.success;
      } else {
        statusText = 'ผ้ากำลัง...${signalState.status.name}';
        statusColor = themeColor;
      }
    } else {
      statusColor = _getStatusColor(_currentBooking.status);
      statusText = _getStatusText(_currentBooking.status);
    }

    final isPending = _currentBooking.status == BookingStatus.pending;
    final isInProgress = _currentBooking.status == BookingStatus.inProgress;
    final isCompleted = _currentBooking.status == BookingStatus.completed;

    final canCheckIn = isPending && _isTimeToCheckIn();
    final canComplete =
        isInProgress || signalState.status == MachineWorkStatus.finished;
    final pastEndTime = isInProgress && _isPastEndTime();

    final dateStr = DateFormat(
      'd MMM yyyy',
      'th',
    ).format(_currentBooking.startTime.toLocal());
    final dayStr = DateFormat(
      'EEEE',
      'th',
    ).format(_currentBooking.startTime.toLocal());
    final timeRange =
        '${DateFormat('HH:mm').format(_currentBooking.startTime.toLocal())} - ${DateFormat('HH:mm').format(_currentBooking.endTime.toLocal())}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                backgroundColor: themeColor,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    child: const BackButton(color: Colors.white),
                  ),
                ),
                actions: [
                  if (machine != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.2),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReportMachineScreen(machine: machine!),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              themeColor,
                              themeColor.withValues(alpha: 0.8),
                              isWasher
                                  ? AppTheme.primaryDark
                                  : AppTheme.accentDark,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -50,
                        top: -50,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: 1.1),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOutSine,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.2 * value,
                                          ),
                                          blurRadius: 40 * value,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: MachineIllustration(
                                      machineType:
                                          machine?.machineType ??
                                          MachineType.washer,
                                      size: 110,
                                      primaryColor: Colors.white,
                                      secondaryColor: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              machine != null
                                  ? 'เครื่อง ${machine.machineNumber}'
                                  : 'ข้อมูลเครื่อง',
                              style: GoogleFonts.prompt(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusTile(
                            statusText,
                            statusColor,
                            _currentBooking.status == BookingStatus.completed,
                            signalState.status,
                          ),
                          const SizedBox(height: 16),
                          _buildQueueStatus(),
                          const SizedBox(height: 32),
                          Text(
                            'วันและเวลาที่จอง',
                            style: GoogleFonts.prompt(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoSection(
                            items: [
                              _InfoItem(
                                Icons.calendar_today_rounded,
                                'วันที่',
                                '$dayStr $dateStr',
                              ),
                              _InfoItem(
                                Icons.access_time_rounded,
                                'เวลาที่จอง',
                                timeRange,
                              ),
                              _InfoItem(
                                Icons.history_rounded,
                                'ระยะเวลา',
                                '${_currentBooking.durationMinutes} นาที',
                              ),
                              if (_currentBooking.checkedInAt != null)
                                _InfoItem(
                                  Icons.login_rounded,
                                  'เริ่มใช้งานจริง',
                                  DateFormat(
                                    'HH:mm',
                                  ).format(
                                    _currentBooking.checkedInAt!.toLocal(),
                                  ),
                                ),
                              if (_currentBooking.completedAt != null)
                                _InfoItem(
                                  Icons.verified_rounded,
                                  'เสร็จสิ้นเมื่อ',
                                  DateFormat(
                                    'HH:mm',
                                  ).format(
                                    _currentBooking.completedAt!.toLocal(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'รายละเอียดเครื่อง',
                            style: GoogleFonts.prompt(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (machine != null)
                            GridView.count(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.5,
                              children: [
                                _buildGridItem(
                                  icon: Icons.scale_rounded,
                                  label: 'ความจุ',
                                  value: '${machine.capacity} กก.',
                                  color: AppTheme.success,
                                ),
                                _buildGridItem(
                                  icon: Icons.location_on_rounded,
                                  label: 'ตำแหน่ง',
                                  value: 'ชั้น ${machine.floor}',
                                  color: AppTheme.warning,
                                ),
                                _buildGridItem(
                                  icon: Icons.timer_outlined,
                                  label: 'เวลา',
                                  value: isWasher ? '40 นาที' : '50 นาที',
                                  color: AppTheme.primary,
                                ),
                                _buildGridItem(
                                  icon: Icons.payments_rounded,
                                  label: 'ราคา',
                                  value: '${machine.price} บาท',
                                  color: AppTheme.accent,
                                ),
                              ],
                            ),
                          const SizedBox(height: 32),
                          if (isInProgress || isCompleted) ...[
                            _buildSimulationCard(signalState),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background.withValues(alpha: 0.0),
                    AppTheme.background.withValues(alpha: 0.9),
                    AppTheme.background,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canCheckIn || canComplete)
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              statusColor,
                              statusColor.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : (canCheckIn
                                    ? () => _handleCheckIn()
                                    : () => _handleComplete()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      canCheckIn
                                          ? Icons.qr_code_scanner_rounded
                                          : (signalState.status ==
                                                    MachineWorkStatus.finished
                                                ? Icons
                                                      .check_circle_outline_rounded
                                                : (pastEndTime
                                                      ? Icons
                                                            .check_circle_rounded
                                                      : Icons
                                                            .stop_circle_rounded)),
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      canCheckIn
                                          ? 'สแกน QR เพื่อเริ่มซัก'
                                          : (signalState.status ==
                                                    MachineWorkStatus.finished
                                                ? 'เสร็จสิ้น (กดเพื่อรับผ้า)'
                                                : (pastEndTime
                                                      ? 'รับผ้าเสร็จสิ้น'
                                                      : 'เสร็จสิ้นการใช้งาน')),
                                      style: GoogleFonts.prompt(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    _buildSecondaryButton(
                      onTap: () => _handleCancel(),
                      label: 'ยกเลิกการจอง',
                      color: AppTheme.error,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatus() {
    if (_currentBooking.status != BookingStatus.pending) {
      return const SizedBox.shrink();
    }

    final queueAsync = ref.watch(
      machineQueueProvider(_currentBooking.machineId),
    );

    return queueAsync.when(
      data: (queue) {
        final position = queue.indexWhere(
          (item) => (item['booking'] as Booking).id == _currentBooking.id,
        );

        if (position == -1) return const SizedBox.shrink();

        final ahead = queue.take(position).where((item) {
          final b = item['booking'] as Booking;
          return b.status == BookingStatus.pending;
        }).length;

        final isNext = ahead == 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isNext
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isNext
                  ? AppTheme.success.withValues(alpha: 0.3)
                  : AppTheme.neutral200,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNext ? 'ถึงคิวของคุณแล้ว!' : 'ลำดับคิวของคุณ',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      isNext
                          ? 'กรุณาไปที่เครื่องเพื่อเริ่มใช้งาน'
                          : 'รออีก $ahead คิวจะถึงตาคุณ',
                      style: GoogleFonts.prompt(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNext)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'คิวที่ ${ahead + 1}',
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusTile(
    String text,
    Color color,
    bool isCompleted,
    MachineWorkStatus workStatus,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สถานะการจอง',
                  style: GoogleFonts.prompt(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.prompt(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (workStatus != MachineWorkStatus.idle) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        workStatus == MachineWorkStatus.finished
                            ? Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: color,
                              )
                            : SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 8),
                        Text(
                          workStatus == MachineWorkStatus.finished
                              ? 'รอรับผ้าคืน'
                              : 'ระบบกำลังทำงาน...',
                          style: GoogleFonts.prompt(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppTheme.success,
                      size: 28,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: color,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimulationCard(MachineSignalState signalState) {
    final themeColor = _currentBooking.startTime.minute % 2 == 0
        ? AppTheme.primary
        : AppTheme.accent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: themeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Real-time Sensor',
                    style: GoogleFonts.prompt(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (signalState.status != MachineWorkStatus.idle)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    signalState.status == MachineWorkStatus.finished
                        ? 'เสร็จสิ้น'
                        : 'กำลังทำงาน',
                    style: GoogleFonts.prompt(
                      fontSize: 10,
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSensorTile(
                  'Amperage',
                  '${signalState.currentAmps.toStringAsFixed(2)} A',
                  Icons.electrical_services_rounded,
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorTile(
                  'Power',
                  '${(signalState.currentAmps * 220).toStringAsFixed(0)} W',
                  Icons.bolt_rounded,
                  AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral100),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.prompt(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
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
        ],
      ),
    );
  }

  Widget _buildInfoSection({required List<_InfoItem> items}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.neutral100),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.prompt(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          item.value,
                          style: GoogleFonts.prompt(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (idx < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppTheme.neutral100, height: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.prompt(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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

  Widget _buildSecondaryButton({
    required VoidCallback onTap,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        onPressed: _isProcessing ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.prompt(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    _showActionDialog(
      context: context,
      title: 'สแกน QR (จำลอง)',
      body: 'ระบบกำลังจำลองการสแกน QR เพื่อเริ่มต้นการทำงานของเครื่องซักผ้า',
      confirmLabel: 'เริ่มใช้งาน',
      icon: Icons.play_circle_filled_rounded,
      color: AppTheme.primary,
      onConfirm: () async {
        setState(() => _isProcessing = true);
        try {
          await ref.read(bookingProvider).checkInBooking(_currentBooking.id);

          ref
              .read(machineSignalProvider.notifier)
              .startMockWashing(
                machineId: _currentBooking.machineId,
                bookingId: _currentBooking.id,
              );

          ref.invalidate(myBookingsProvider);
          ref.invalidate(activeBookingsProvider);
          ref.invalidate(machineProvider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      },
    );
  }

  Future<void> _handleComplete() async {
    final rawSignalState = ref.read(machineSignalProvider);
    final isFinished =
        rawSignalState.machineId == _currentBooking.machineId &&
        rawSignalState.status == MachineWorkStatus.finished;

    _showActionDialog(
      context: context,
      title: isFinished ? 'รับผ้าเสร็จสิ้น?' : 'ซักผ้าเสร็จแล้ว?',
      body: isFinished
          ? 'คุณต้องการยืนยันว่าได้รับผ้าคืนเรียบร้อยแล้วใช่หรือไม่?'
          : 'คุณต้องการยืนยันว่าการซักผ้าเสร็จสิ้นแล้วใช่หรือไม่?\n(เครื่องจะหยุดทำงานทันที)',
      confirmLabel: 'ยืนยัน',
      icon: Icons.check_circle_rounded,
      color: AppTheme.success,
      onConfirm: () async {
        setState(() => _isProcessing = true);
        try {
          if (isFinished) {
            ref.read(machineSignalProvider.notifier).resetWork();
          }
          await ref.read(bookingProvider).completeBooking(_currentBooking.id);
          ref.invalidate(myBookingsProvider);
          ref.invalidate(activeBookingsProvider);
          ref.invalidate(machineProvider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      },
    );
  }

  Future<void> _handleCancel() async {
    _showActionDialog(
      context: context,
      title: 'ยกเลิกการจอง?',
      body:
          'คุณต้องการยกเลิกการจองนี้ใช่หรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
      confirmLabel: 'ยืนยันการยกเลิก',
      icon: Icons.cancel_outlined,
      color: AppTheme.error,
      onConfirm: () async {
        setState(() => _isProcessing = true);
        try {
          await ref.read(bookingProvider).cancelBooking(_currentBooking.id);
          ref.invalidate(myBookingsProvider);
          ref.invalidate(activeBookingsProvider);
          ref.invalidate(machineProvider);
          if (mounted) Navigator.pop(context);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      },
    );
  }

  void _showActionDialog({
    required BuildContext context,
    required String title,
    required String body,
    required String confirmLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          body,
          style: GoogleFonts.prompt(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'ยกเลิก',
                    style: GoogleFonts.prompt(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    confirmLabel,
                    style: GoogleFonts.prompt(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem(this.icon, this.label, this.value);
}

extension on Machine {
  int get price => 20;
}
