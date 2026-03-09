import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/screens/components/machine_illustration.dart';
import 'package:laundry_app/screens/booking_detail.dart';
import 'package:intl/intl.dart';

enum BookingFilter { all, active, completed, cancelled }

class MyBookingsScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  const MyBookingsScreen({super.key, this.showBackButton = false});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  BookingFilter _currentFilter = BookingFilter.all;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    Future.microtask(() {
      ref.read(bookingProvider).checkOverdueBookings();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Booking> _applyFilter(List<Booking> bookings) {
    switch (_currentFilter) {
      case BookingFilter.all:
        return bookings;
      case BookingFilter.active:
        return bookings
            .where(
              (b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.checkedIn ||
                  b.status == BookingStatus.inProgress,
            )
            .toList();
      case BookingFilter.completed:
        return bookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      case BookingFilter.cancelled:
        return bookings
            .where(
              (b) =>
                  b.status == BookingStatus.cancelled ||
                  b.status == BookingStatus.noShow,
            )
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    final machinesAsync = ref.watch(machineProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.showBackButton
          ? AppBar(
              backgroundColor: AppTheme.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppTheme.textPrimary,
                ),
              ),
              title: Text(
                'การจองของฉัน',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: bookingsAsync.when(
          data: (bookings) {
            final sorted = [...bookings];
            sorted.sort((a, b) => b.startTime.compareTo(a.startTime));

            final filtered = _applyFilter(sorted);

            final activeCount = bookings
                .where(
                  (b) =>
                      b.status == BookingStatus.pending ||
                      b.status == BookingStatus.checkedIn ||
                      b.status == BookingStatus.inProgress,
                )
                .length;
            final completedCount = bookings
                .where((b) => b.status == BookingStatus.completed)
                .length;
            final cancelledCount = bookings
                .where(
                  (b) =>
                      b.status == BookingStatus.cancelled ||
                      b.status == BookingStatus.noShow,
                )
                .length;

            return FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(
                      total: bookings.length,
                      active: activeCount,
                      completed: completedCount,
                      cancelled: cancelledCount,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _buildFilterChips(
                      activeCount: activeCount,
                      completedCount: completedCount,
                      cancelledCount: cancelledCount,
                      totalCount: bookings.length,
                    ),
                  ),

                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final booking = filtered[index];
                            Machine? machine;
                            if (machinesAsync.hasValue) {
                              machine = machinesAsync.value!
                                  .cast<Machine?>()
                                  .firstWhere(
                                    (m) => m?.id == booking.machineId,
                                    orElse: () => null,
                                  );
                            }
                            return _BookingCard(
                              booking: booking,
                              machine: machine,
                              index: index,
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppTheme.error.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'เกิดข้อผิดพลาด',
                  style: GoogleFonts.prompt(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$err',
                  style: GoogleFonts.prompt(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required int total,
    required int active,
    required int completed,
    required int cancelled,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF4DA8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'การจองของฉัน',
                    style: GoogleFonts.prompt(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'ทั้งหมด $total รายการ',
                    style: GoogleFonts.prompt(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildStatBadge(
                label: 'กำลังใช้',
                count: active,
                color: AppTheme.warningLight,
              ),
              const SizedBox(width: 10),
              _buildStatBadge(
                label: 'สำเร็จ',
                count: completed,
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 10),
              _buildStatBadge(
                label: 'ยกเลิก',
                count: cancelled,
                color: AppTheme.errorLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.prompt(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.prompt(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips({
    required int activeCount,
    required int completedCount,
    required int cancelledCount,
    required int totalCount,
  }) {
    final filters = [
      _FilterItem(
        BookingFilter.all,
        'ทั้งหมด',
        totalCount,
        Icons.list_alt_rounded,
        AppTheme.primary,
      ),
      _FilterItem(
        BookingFilter.active,
        'ดำเนินการ',
        activeCount,
        Icons.timelapse_rounded,
        AppTheme.warning,
      ),
      _FilterItem(
        BookingFilter.completed,
        'สำเร็จ',
        completedCount,
        Icons.check_circle_rounded,
        AppTheme.success,
      ),
      _FilterItem(
        BookingFilter.cancelled,
        'ยกเลิก',
        cancelledCount,
        Icons.cancel_rounded,
        AppTheme.error,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral100, width: 1),
      ),
      child: Row(
        children: filters.map((f) {
          final isSelected = _currentFilter == f.filter;
          final accentColor = f.accentColor;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentFilter = f.filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${f.count}',
                        style: GoogleFonts.prompt(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? accentColor : AppTheme.neutral400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      f.label,
                      style: GoogleFonts.prompt(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.textPrimary
                            : AppTheme.neutral400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isSelected ? 16 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_currentFilter) {
      case BookingFilter.all:
        message = 'ยังไม่มีประวัติการจอง';
        icon = Icons.event_note_rounded;
        break;
      case BookingFilter.active:
        message = 'ไม่มีการจองที่กำลังดำเนินการ';
        icon = Icons.timelapse_rounded;
        break;
      case BookingFilter.completed:
        message = 'ยังไม่มีการจองที่สำเร็จ';
        icon = Icons.check_circle_outline_rounded;
        break;
      case BookingFilter.cancelled:
        message = 'ไม่มีการจองที่ถูกยกเลิก';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: AppTheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: GoogleFonts.prompt(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'จองเครื่องซักผ้าได้ที่หน้าหลัก',
            style: GoogleFonts.prompt(
              fontSize: 13,
              color: AppTheme.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterItem {
  final BookingFilter filter;
  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;
  const _FilterItem(
    this.filter,
    this.label,
    this.count,
    this.icon,
    this.accentColor,
  );
}

Color _statusColor(BookingStatus status) {
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

String _statusText(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return 'รอใช้งาน';
    case BookingStatus.checkedIn:
      return 'เช็คอินแล้ว';
    case BookingStatus.inProgress:
      return 'กำลังซัก';
    case BookingStatus.completed:
      return 'เสร็จสิ้น';
    case BookingStatus.cancelled:
      return 'ยกเลิกแล้ว';
    case BookingStatus.noShow:
      return 'ไม่มาใช้งาน';
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  final Machine? machine;
  final int index;

  const _BookingCard({
    required this.booking,
    required this.machine,
    required this.index,
  });

  bool _isPastEndTime() {
    final now = DateTime.now();
    return now.isAfter(booking.endTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(booking.status);
    final isPending = booking.status == BookingStatus.pending;
    final isInProgress = booking.status == BookingStatus.inProgress;
    final isCompleted = booking.status == BookingStatus.completed;
    final isCancelled =
        booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.noShow;

    final canComplete = isInProgress;
    final pastEndTime = isInProgress && _isPastEndTime();

    final dateStr = DateFormat(
      'd MMM yyyy',
      'th',
    ).format(booking.startTime.toLocal());
    final dayStr = DateFormat('EEE', 'th').format(booking.startTime.toLocal());
    final timeStr =
        '${DateFormat('HH:mm').format(booking.startTime.toLocal())} - ${DateFormat('HH:mm').format(booking.endTime.toLocal())}';

    final isWasher = machine?.machineType == MachineType.washer;
    final machineLabel = machine != null
        ? (isWasher ? "เครื่องซักผ้า" : "เครื่องอบผ้า")
        : 'เครื่อง';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailScreen(booking: booking),
              ),
            );
          },
          child: Column(
            children: [
              SizedBox(
                height: (isPending || isInProgress) ? 170 : 140,
                child: Row(
                  children: [
                    Container(
                      width: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isWasher
                              ? [
                                  AppTheme.primaryLight,
                                  AppTheme.primaryLightest,
                                ]
                              : [AppTheme.accentLight, AppTheme.accentLightest],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Opacity(
                              opacity: isCancelled ? 0.4 : 1.0,
                              child: machine != null
                                  ? MachineIllustration(
                                      machineType: machine!.machineType,
                                      size: 72,
                                    )
                                  : Icon(
                                      Icons.local_laundry_service_rounded,
                                      size: 48,
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          if (machine != null)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isWasher
                                      ? AppTheme.primary
                                      : AppTheme.accentDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  machine!.machineNumber,
                                  style: GoogleFonts.prompt(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    machineLabel,
                                    style: GoogleFonts.prompt(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled
                                          ? AppTheme.neutral400
                                          : AppTheme.textPrimary,
                                      decoration: isCancelled
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                _buildBadge(
                                  '$dayStr $dateStr',
                                  isWasher
                                      ? AppTheme.primary
                                      : AppTheme.accentDark,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: AppTheme.neutral400,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  timeStr,
                                  style: GoogleFonts.prompt(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: AppTheme.neutral400,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${booking.durationMinutes} นาที',
                                  style: GoogleFonts.prompt(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _statusText(booking.status),
                                    style: GoogleFonts.prompt(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: AppTheme.success,
                                  ),
                                ],
                                const Spacer(),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isPending)
                                      GestureDetector(
                                        onTap: () =>
                                            _showCancelDialog(context, ref),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.error.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: AppTheme.error.withValues(
                                                alpha: 0.25,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.close_rounded,
                                                size: 14,
                                                color: AppTheme.error,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'ยกเลิก',
                                                style: GoogleFonts.prompt(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    if (canComplete)
                                      GestureDetector(
                                        onTap: () =>
                                            _showCompleteDialog(context, ref),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: pastEndTime
                                                  ? [
                                                      AppTheme.success,
                                                      const Color(0xFF7DD9A0),
                                                    ]
                                                  : [
                                                      const Color(0xFF5B9CF6),
                                                      const Color(0xFF7DB8F8),
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (pastEndTime
                                                            ? AppTheme.success
                                                            : const Color(
                                                                0xFF5B9CF6,
                                                              ))
                                                        .withValues(
                                                          alpha: 0.3,
                                                        ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                pastEndTime
                                                    ? Icons.check_circle_rounded
                                                    : Icons.stop_circle_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                pastEndTime
                                                    ? 'รับผ้า'
                                                    : 'เสร็จสิ้น',
                                                style: GoogleFonts.prompt(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.prompt(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  color: AppTheme.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'ยกเลิกการจอง?',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'คุณต้องการยกเลิกการจองนี้ใช่หรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
                textAlign: TextAlign.center,
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.neutral200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'ไม่ใช่',
                        style: GoogleFonts.prompt(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(bookingProvider)
                            .cancelBooking(booking.id);
                        ref.invalidate(myBookingsProvider);
                        ref.invalidate(activeBookingsProvider);
                        ref.invalidate(machineProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showCompleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'ซักผ้าเสร็จแล้ว?',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ยืนยันว่าคุณรับผ้าออกจากเครื่องแล้ว\nเครื่องจะว่างให้คนอื่นใช้ต่อ',
                textAlign: TextAlign.center,
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.neutral200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'ยังก่อน',
                        style: GoogleFonts.prompt(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref
                            .read(bookingProvider)
                            .completeBooking(booking.id);
                        ref.invalidate(myBookingsProvider);
                        ref.invalidate(activeBookingsProvider);
                        ref.invalidate(machineProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'เสร็จสิ้น',
                        style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
