import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/providers/machine_signal_provider.dart';
import 'package:laundry_app/screens/components/machine_illustration.dart';
import 'package:laundry_app/screens/report_machine.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:intl/intl.dart';

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
  String get _duration => _isWasher ? '40 นาที' : '50 นาที';

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(machineProvider);
    final activeBookingsAsync = ref.watch(activeBookingsProvider);
    final rawSignalState = ref.watch(machineSignalProvider);

    final machine = machinesAsync.maybeWhen(
      data: (list) => list.firstWhere(
        (m) => m.id == widget.machine.id,
        orElse: () => widget.machine,
      ),
      orElse: () => widget.machine,
    );

    final signalState = rawSignalState.machineId == machine.id
        ? rawSignalState
        : MachineSignalState(status: MachineWorkStatus.idle);

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final now = DateTime.now();
    final myActiveBooking = activeBookingsAsync.maybeWhen(
      data: (bookings) {
        final myBookings = bookings
            .where(
              (b) => b.machineId == machine.id && b.userId == currentUserId,
            )
            .toList();

        if (myBookings.isEmpty) return null;

        myBookings.sort((a, b) => a.startTime.compareTo(b.startTime));

        try {
          return myBookings.firstWhere(
            (b) => b.status == BookingStatus.inProgress,
          );
        } catch (_) {}

        return myBookings.first;
      },
      orElse: () => null,
    );

    final isBooked = activeBookingsAsync.maybeWhen(
      data: (bookings) => bookings.any((b) => b.machineId == machine.id),
      orElse: () => false,
    );

    final isActuallyAvailable =
        machine.status == MachineStatus.available && !isBooked;

    final canBookNext = machine.status != MachineStatus.maintenance;

    final isReadyToStart =
        myActiveBooking != null &&
        (myActiveBooking.status == BookingStatus.pending ||
            myActiveBooking.status == BookingStatus.checkedIn) &&
        now.isAfter(
          myActiveBooking.startTime.toLocal().subtract(
            const Duration(minutes: 15),
          ),
        );

    final canStartNow =
        myActiveBooking != null &&
        (myActiveBooking.status == BookingStatus.pending ||
            myActiveBooking.status == BookingStatus.checkedIn) &&
        isReadyToStart;

    Color statusColor;
    String statusText;

    if (signalState.status != MachineWorkStatus.idle) {
      if (signalState.status == MachineWorkStatus.finished) {
        statusText = 'ซักผ้าเสร็จแล้ว!';
        statusColor = AppTheme.success;
      } else {
        statusText = 'ผ้ากำลัง...${signalState.status.name}';
        statusColor = _machineColor;
      }
    } else if (myActiveBooking != null) {
      statusColor = isReadyToStart ? _machineColor : AppTheme.warning;
      if (myActiveBooking.status == BookingStatus.inProgress) {
        statusText = 'ผ้าคุณกำลังซักอยู่';
      } else if (isReadyToStart) {
        statusText = 'ถึงคิวของคุณแล้ว';
      } else {
        final timeStr = DateFormat(
          'HH:mm',
        ).format(myActiveBooking.startTime.toLocal());
        statusText = 'คุณมีการจองรอบ $timeStr น.';
      }
    } else {
      statusColor = isActuallyAvailable
          ? AppTheme.success
          : (machine.status == MachineStatus.available
                ? AppTheme.error
                : _getStatusColor(machine.status));

      statusText = isActuallyAvailable
          ? 'พร้อมใช้งาน'
          : (isBooked
                ? 'ไม่ว่าง (ติดจอง/กำลังซัก)'
                : _getStatusText(machine.status));
    }

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
                backgroundColor: _machineColor,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    child: const BackButton(color: Colors.white),
                  ),
                ),
                actions: [
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
                                  ReportMachineScreen(machine: machine),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'รายงานปัญหา',
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
                              _machineColor,
                              _machineColor.withValues(alpha: 0.8),
                              _isWasher
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
                                      machineType: machine.machineType,
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
                              'เครื่อง ${machine.machineNumber}',
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
                            isActuallyAvailable,
                            myActiveBooking,
                            signalState.status,
                          ),

                          const SizedBox(height: 32),

                          Text(
                            'ข้อมูลเครื่อง',
                            style: GoogleFonts.prompt(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                icon: Icons.payments_rounded,
                                label: 'ราคา',
                                value: '${machine.price} บาท',
                                color: AppTheme.warning,
                              ),
                              _buildGridItem(
                                icon: Icons.timer_outlined,
                                label: 'เวลา',
                                value: _duration,
                                color: AppTheme.primary,
                              ),
                              _buildGridItem(
                                icon: Icons.category_rounded,
                                label: 'ประเภท',
                                value: _isWasher ? 'ซักผ้า' : 'อบผ้า',
                                color: AppTheme.accent,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          _buildSimulationCard(signalState),

                          const SizedBox(height: 24),
                          _buildUpcomingQueue(machine.id),

                          const SizedBox(
                            height: 100,
                          ),
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
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: canBookNext
                        ? LinearGradient(
                            colors: [
                              _machineColor.withValues(
                                alpha: isActuallyAvailable ? 1.0 : 0.8,
                              ),
                              (_isWasher
                                      ? AppTheme.primaryDark
                                      : AppTheme.accentDark)
                                  .withValues(
                                    alpha: isActuallyAvailable ? 1.0 : 0.8,
                                  ),
                            ],
                          )
                        : null,
                    color: !canBookNext ? AppTheme.neutral200 : null,
                    boxShadow: canBookNext
                        ? [
                            BoxShadow(
                              color: _machineColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed:
                        (canBookNext &&
                            !_isBooking &&
                            signalState.status == MachineWorkStatus.idle)
                        ? (canStartNow
                              ? () => _handleCheckIn(myActiveBooking)
                              : () => _handleBooking(machine))
                        : (signalState.status == MachineWorkStatus.finished
                              ? () => ref
                                    .read(machineSignalProvider.notifier)
                                    .resetWork()
                              : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
                                signalState.status == MachineWorkStatus.finished
                                    ? Icons.check_circle_outline_rounded
                                    : (canStartNow &&
                                              signalState.status ==
                                                  MachineWorkStatus.idle
                                          ? Icons.qr_code_scanner_rounded
                                          : (isActuallyAvailable
                                                ? Icons
                                                      .add_circle_outline_rounded
                                                : (signalState.status !=
                                                          MachineWorkStatus.idle
                                                      ? Icons
                                                            .hourglass_bottom_rounded
                                                      : Icons.redo_rounded))),
                                color:
                                    (canBookNext ||
                                        signalState.status ==
                                            MachineWorkStatus.finished)
                                    ? Colors.white
                                    : AppTheme.neutral400,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                signalState.status == MachineWorkStatus.finished
                                    ? 'เสร็จสิ้น (กดเพื่อรับผ้า)'
                                    : (canStartNow &&
                                              signalState.status ==
                                                  MachineWorkStatus.idle
                                          ? 'สแกน QR เพื่อเริ่มซัก'
                                          : (isActuallyAvailable
                                                ? 'จองคิวเลย'
                                                : (canBookNext
                                                      ? 'จองคิวต่อไป'
                                                      : statusText))),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.prompt(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (canBookNext ||
                                          signalState.status ==
                                              MachineWorkStatus.finished)
                                      ? Colors.white
                                      : AppTheme.neutral400,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(
    String text,
    Color color,
    bool isAvailable,
    Booking? myBooking,
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
                  'สถานะการทำงาน',
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
                if (myBooking != null &&
                    workStatus == MachineWorkStatus.idle &&
                    myBooking.status != BookingStatus.inProgress) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_person_rounded,
                          size: 14,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ล็อคคิวเฉพาะคุณ (กดเพื่อเริ่ม)',
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
          if (isAvailable)
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
            ),
        ],
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

  Widget _buildSimulationCard(MachineSignalState signalState) {
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
                      color: _machineColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: _machineColor,
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

  Future<void> _handleCheckIn(Booking booking) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('สแกน QR สำเร็จ (จำลอง)', style: GoogleFonts.prompt()),
        content: Text(
          'ระบบจำลองการสแกน QR สำเร็จแล้ว\nกดเพื่อเริ่มการทำงานของเครื่องและเซ็นเซอร์',
          style: GoogleFonts.prompt(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก', style: GoogleFonts.prompt()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isBooking = true);
              try {
                await ref.read(bookingProvider).checkInBooking(booking.id);

                ref
                    .read(machineSignalProvider.notifier)
                    .startMockWashing(
                      machineId: widget.machine.id,
                      bookingId: booking.id,
                    );

                ref.invalidate(myBookingsProvider);
                ref.invalidate(activeBookingsProvider);
                ref.invalidate(machineProvider);
              } finally {
                if (mounted) setState(() => _isBooking = false);
              }
            },
            child: Text('เริ่มใช้งาน', style: GoogleFonts.prompt()),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking(Machine machine) async {
    final now = DateTime.now();
    final nowUtc = now.toUtc();

    DateTime suggestedStartTime = now.add(const Duration(minutes: 5));

    final activeBookingsAsync = ref.read(activeBookingsProvider);
    activeBookingsAsync.whenData((bookings) {
      final machineBookings = bookings
          .where((b) => b.machineId == machine.id)
          .toList();
      if (machineBookings.isNotEmpty) {
        machineBookings.sort((a, b) => b.endTime.compareTo(a.endTime));
        final latestBooking = machineBookings.first;

        if (latestBooking.endTime.isAfter(nowUtc)) {
          suggestedStartTime = latestBooking.endTime.toLocal().add(
            const Duration(minutes: 2),
          );
        }
      }
    });

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: suggestedStartTime,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _machineColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(suggestedStartTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _machineColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null || !mounted) return;

    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถจองเวลาย้อนหลังได้',
            style: GoogleFonts.prompt(),
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

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
                  _buildDialogRow('เครื่อง', machine.machineNumber),
                  const SizedBox(height: 8),
                  _buildDialogRow('เวลา', time.format(context)),
                  const SizedBox(height: 8),
                  _buildDialogRow('ราคา', '${machine.price} บาท'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'หากไม่มาใช้งานภายใน 5 นาที คิวจะหลุดโดยอัตโนมัติ',
                            style: GoogleFonts.prompt(
                              fontSize: 11,
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            machineId: machine.id,
            machineNumber: machine.machineNumber,
            startTime: selectedDateTime,
            durationMinutes: durationMinutes,
          );

      if (mounted) {
        ref.invalidate(activeBookingsProvider);
        ref.invalidate(machineProvider);
        ref.invalidate(machineQueueProvider(machine.id));

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

  Widget _buildUpcomingQueue(String machineId) {
    final queueAsync = ref.watch(machineQueueProvider(machineId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'คิวรอใช้งาน',
              style: GoogleFonts.prompt(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        queueAsync.when(
          data: (queue) {
            if (queue.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.neutral200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      color: AppTheme.neutral300,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ยังไม่มีคิวในขณะนี้',
                      style: GoogleFonts.prompt(
                        color: AppTheme.neutral400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final item = queue[index];
                final booking = item['booking'] as Booking;
                final userName = item['userName'] as String;
                final isCurrent =
                    booking.status == BookingStatus.inProgress ||
                    booking.status == BookingStatus.checkedIn;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? _machineColor.withValues(alpha: 0.05)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? _machineColor.withValues(alpha: 0.2)
                          : AppTheme.neutral200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _machineColor
                              : AppTheme.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            isCurrent ? '●' : '${index + 1}',
                            style: GoogleFonts.prompt(
                              color: isCurrent
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              isCurrent ? 'กำลังใช้งาน' : 'รอรับบริการ...',
                              style: GoogleFonts.prompt(
                                fontSize: 12,
                                color: isCurrent
                                    ? _machineColor
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(booking.startTime.toLocal()),
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
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
