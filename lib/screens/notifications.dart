import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/screens/my_bookings.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    final machinesAsync = ref.watch(machineProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
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
          'การแจ้งเตือน',
          style: GoogleFonts.prompt(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return _buildEmptyState();
          }

          final machineMap = <String, Machine>{};
          if (machinesAsync.hasValue) {
            for (final m in machinesAsync.value!) {
              machineMap[m.id] = m;
            }
          }

          // Build notification items from bookings, sorted newest first
          final notifications = _buildNotifications(bookings, machineMap);

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          final grouped = <String, List<_NotifItem>>{};
          for (final n in notifications) {
            final key = _dateGroupLabel(n.time);
            grouped.putIfAbsent(key, () => []).add(n);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: grouped.length,
            itemBuilder: (context, sectionIndex) {
              final label = grouped.keys.elementAt(sectionIndex);
              final items = grouped[label]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sectionIndex > 0) const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.prompt(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  ...items.map(
                    (item) => _NotificationCard(item: item),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'เกิดข้อผิดพลาด',
            style: GoogleFonts.prompt(color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: AppTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ยังไม่มีการแจ้งเตือน',
            style: GoogleFonts.prompt(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เมื่อคุณจองเครื่องซักผ้า\nการแจ้งเตือนจะปรากฏที่นี่',
            textAlign: TextAlign.center,
            style: GoogleFonts.prompt(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'วันนี้';
    if (diff == 1) return 'เมื่อวาน';
    if (diff < 7) return '$diff วันที่แล้ว';
    return DateFormat('d MMM yyyy', 'th').format(date);
  }

  List<_NotifItem> _buildNotifications(
    List<Booking> bookings,
    Map<String, Machine> machines,
  ) {
    final items = <_NotifItem>[];

    for (final b in bookings) {
      final machine = machines[b.machineId];
      final isWasher = machine?.machineType == MachineType.washer;
      final machineName = machine != null
          ? '${isWasher ? "เครื่องซักผ้า" : "เครื่องอบผ้า"} ${machine.machineNumber}'
          : 'เครื่อง';
      final timeStr =
          '${b.startTime.substring(0, 5)} - ${b.endTime.substring(0, 5)}';

      switch (b.status) {
        case BookingStatus.pending:
          items.add(
            _NotifItem(
              icon: Icons.check_circle_rounded,
              color: AppTheme.success,
              title: 'จองสำเร็จ',
              body: '$machineName เวลา $timeStr',
              time: b.bookingDate,
              type: _NotifType.success,
            ),
          );
        case BookingStatus.checkedIn:
          items.add(
            _NotifItem(
              icon: Icons.login_rounded,
              color: AppTheme.primary,
              title: 'เช็คอินแล้ว',
              body: '$machineName เริ่มใช้งานได้เลย',
              time: b.bookingDate,
              type: _NotifType.info,
            ),
          );
        case BookingStatus.inProgress:
          items.add(
            _NotifItem(
              icon: Icons.local_laundry_service_rounded,
              color: AppTheme.primary,
              title: 'กำลังซักอยู่',
              body: '$machineName กำลังทำงาน',
              time: b.bookingDate,
              type: _NotifType.info,
            ),
          );
        case BookingStatus.completed:
          items.add(
            _NotifItem(
              icon: Icons.verified_rounded,
              color: AppTheme.success,
              title: 'ซักเสร็จแล้ว',
              body: '$machineName เสร็จเรียบร้อย',
              time: b.completedAt ?? b.bookingDate,
              type: _NotifType.success,
            ),
          );
        case BookingStatus.cancelled:
          items.add(
            _NotifItem(
              icon: Icons.cancel_rounded,
              color: AppTheme.error,
              title: 'ยกเลิกการจอง',
              body: '$machineName เวลา $timeStr',
              time: b.bookingDate,
              type: _NotifType.cancelled,
            ),
          );
        case BookingStatus.noShow:
          items.add(
            _NotifItem(
              icon: Icons.person_off_rounded,
              color: AppTheme.warning,
              title: 'ไม่มาใช้งาน',
              body: '$machineName เวลา $timeStr',
              time: b.bookingDate,
              type: _NotifType.warning,
            ),
          );
      }
    }

    // Sort newest first
    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }
}

enum _NotifType { success, info, warning, cancelled }

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final DateTime time;
  final _NotifType type;

  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotifItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(item.time);

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent
            Container(
              width: 4,
              color: item.color,
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.body,
                            style: GoogleFonts.prompt(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Time
                    Text(
                      timeStr,
                      style: GoogleFonts.prompt(
                        fontSize: 11,
                        color: AppTheme.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
