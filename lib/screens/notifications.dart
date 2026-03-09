import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/screens/booking_detail.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: grouped.length,
            itemBuilder: (context, sectionIndex) {
              final label = grouped.keys.elementAt(sectionIndex);
              final items = grouped[label]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      bottom: 12,
                      top: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: GoogleFonts.prompt(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
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
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightest,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 80,
                color: AppTheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ยังไม่มีการแจ้งเตือน',
              style: GoogleFonts.prompt(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ติดตามสถานะการซักผ้าของคุณได้ที่นี่\nเราจะแจ้งคุณเมื่อเครื่องพร้อมใช้งาน',
              textAlign: TextAlign.center,
              style: GoogleFonts.prompt(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
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
          '${DateFormat('HH:mm').format(b.startTime)} - ${DateFormat('HH:mm').format(b.endTime)}';

      switch (b.status) {
        case BookingStatus.pending:
          items.add(
            _NotifItem(
              icon: Icons.check_circle_rounded,
              color: AppTheme.success,
              title: 'จองสำเร็จ',
              body: '$machineName เวลา $timeStr',
              time: b.startTime,
              type: _NotifType.success,
              booking: b,
            ),
          );
        case BookingStatus.checkedIn:
          items.add(
            _NotifItem(
              icon: Icons.login_rounded,
              color: AppTheme.primary,
              title: 'เช็คอินแล้ว',
              body: '$machineName เริ่มใช้งานได้เลย',
              time: b.startTime,
              type: _NotifType.info,
              booking: b,
            ),
          );
        case BookingStatus.inProgress:
          items.add(
            _NotifItem(
              icon: Icons.local_laundry_service_rounded,
              color: AppTheme.primary,
              title: 'กำลังทำงาน',
              body: '$machineName กำลังดำเนินการซัก/อบ',
              time: b.startTime,
              type: _NotifType.info,
              booking: b,
            ),
          );
        case BookingStatus.completed:
          items.add(
            _NotifItem(
              icon: Icons.verified_rounded,
              color: AppTheme.success,
              title: 'เสร็จเรียบร้อย',
              body: '$machineName ทำงานเสร็จสิ้นแล้ว',
              time: b.completedAt ?? b.startTime,
              type: _NotifType.success,
              booking: b,
            ),
          );
        case BookingStatus.cancelled:
          items.add(
            _NotifItem(
              icon: Icons.cancel_rounded,
              color: AppTheme.error,
              title: 'ยกเลิกการจอง',
              body: '$machineName ยกเลิกการใช้งานแล้ว',
              time: b.startTime,
              type: _NotifType.cancelled,
              booking: b,
            ),
          );
        case BookingStatus.noShow:
          items.add(
            _NotifItem(
              icon: Icons.person_off_rounded,
              color: AppTheme.warning,
              title: 'ไม่ได้เข้าใช้งาน',
              body: 'คุณไม่ได้เข้าใช้งาน $machineName ตามเวลาที่จอง',
              time: b.startTime,
              type: _NotifType.warning,
              booking: b,
            ),
          );
      }
    }

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
  final Booking booking;

  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.booking,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotifItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: item.color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingDetailScreen(booking: item.booking),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.prompt(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: GoogleFonts.prompt(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.neutral300,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
