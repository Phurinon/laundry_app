import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/services/notification_service.dart';
import 'package:uuid/uuid.dart';

final bookingProvider = Provider((ref) => BookingService());

class BookingService {
  final _supabase = Supabase.instance.client;

  Future<void> createBooking({
    required String machineId,
    required String machineNumber,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('กรุณาเข้าสู่ระบบก่อนจอง');
    }

    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final startStr = _formatTime(startTime);
    final endStr = _formatTime(endTime);

    // 1. Check for conflicts
    // We check if there is any booking for this machine that overlaps with our requested time
    // Logic: (StartA < EndB) and (EndA > StartB)
    final existingBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .eq('booking_date', startTime.toIso8601String().split('T')[0])
        .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress')
        .gte('end_time', startStr) // Existing booking ends AFTER our start
        .lte('start_time', endStr); // Existing booking starts BEFORE our end

    if (existingBookings.isNotEmpty) {
      throw Exception('ช่วงเวลานี้มีการจองแล้ว');
    }

    // 2. Create Booking
    final booking = Booking(
      id: const Uuid().v4(),
      userId: userId,
      machineId: machineId,
      bookingDate: startTime,
      startTime: startStr,
      endTime: endStr,
      durationMinutes: durationMinutes,
      status: BookingStatus.pending,
    );

    await _supabase.from('bookings').insert(booking.toJson());

    // 3. Schedule Notification (10 mins before start)
    final notificationTime = startTime.subtract(const Duration(minutes: 10));
    if (notificationTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: booking.id.hashCode,
        title: 'ใกล้ถึงเวลาซักผ้าแล้ว! 🧺',
        body: 'การจองของคุณที่เครื่อง $machineNumber จะเริ่มในอีก 10 นาที',
        scheduledDate: notificationTime,
      );
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';
  }

  Stream<List<Booking>> getMyBookings() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('booking_date', ascending: true) // Upcoming first
        .map((data) => data.map((json) => Booking.fromJson(json)).toList());
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);

    // Cancel Notification
    await NotificationService().cancelNotification(bookingId.hashCode);
  }
}
