import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:intl/intl.dart';

final myBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return ref.watch(bookingProvider).getMyBookings();
});

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'การจองของฉัน',
          style: GoogleFonts.prompt(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                'ไม่มีประวัติการจอง',
                style: GoogleFonts.prompt(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, ref, booking);
            },
          );
        },
        error: (err, stack) => Center(child: Text('เกิดข้อผิดพลาด: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) {
    final isPending = booking.status == BookingStatus.pending;

    Color statusColor;
    String statusText;

    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = 'รอใช้งาน';
        break;
      case BookingStatus.checkedIn:
        statusColor = Colors.blue;
        statusText = 'เช็คอินแล้ว';
        break;
      case BookingStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'กำลังซัก';
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = 'เสร็จสิ้น';
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'ยกเลิกแล้ว';
        break;
      case BookingStatus.noShow:
        statusColor = Colors.grey;
        statusText = 'ไม่มาแสดงตัว';
        break;
    }

    // Format Date and Time
    final dateStr = DateFormat('dd MMM yyyy').format(booking.bookingDate);
    final timeStr =
        '${booking.startTime.substring(0, 5)} - ${booking.endTime.substring(0, 5)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เครื่องซักผ้า', // Ideally fetch machine name using ID, but for now static
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.prompt(color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.prompt(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เวลา: $timeStr',
                style: GoogleFonts.prompt(fontSize: 16),
              ),
              if (isPending)
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'ยกเลิกการจอง',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'คุณต้องการยกเลิกการจองนี้ใช่หรือไม่?',
                          style: GoogleFonts.prompt(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'ไม่',
                              style: GoogleFonts.prompt(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'ใช่, ยกเลิก',
                              style: GoogleFonts.prompt(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(bookingProvider).cancelBooking(booking.id);
                    }
                  },
                  child: Text(
                    'ยกเลิก',
                    style: GoogleFonts.prompt(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
