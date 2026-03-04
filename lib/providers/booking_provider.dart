import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/services/notification_service.dart';
import 'package:uuid/uuid.dart';

final bookingProvider = Provider((ref) => BookingService());

/// Provider that streams all active bookings for today (all users)
/// Used by home screen to determine real machine availability
final activeBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingProvider).getAllActiveBookings();
});

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

    // 3. Update machine status to reserved
    try {
      await _supabase
          .from('machines')
          .update({'status': 'reserved'})
          .eq('id', machineId)
          .select();
    } catch (e) {
      // If machine status update fails (e.g. RLS), log but don't block the booking
      debugPrint('Failed to update machine status: $e');
    }

    // 4. Show instant notification — booking confirmed
    await NotificationService().showNotification(
      id: booking.id.hashCode + 1,
      title: 'จองสำเร็จแล้ว!',
      body:
          'เครื่อง $machineNumber เวลา ${startStr.substring(0, 5)} - ${endStr.substring(0, 5)}',
    );

    // 5. Schedule Notification — 10 mins before start
    final notificationTime = startTime.subtract(const Duration(minutes: 10));
    if (notificationTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: booking.id.hashCode,
        title: 'ใกล้ถึงเวลาซักผ้าแล้ว!',
        body: 'การจองของคุณที่เครื่อง $machineNumber จะเริ่มในอีก 10 นาที',
        scheduledDate: notificationTime,
      );
    }

    // 6. Schedule Notification — at exact start time
    if (startTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: booking.id.hashCode + 2,
        title: 'ถึงเวลาซักผ้าแล้ว!',
        body: 'เครื่อง $machineNumber พร้อมใช้งานแล้ว ไปซักผ้าได้เลย!',
        scheduledDate: startTime,
      );
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';
  }

  /// Stream of all active bookings (any user) for today — used to determine machine availability
  Stream<List<Booking>> getAllActiveBookings() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('start_time', ascending: true)
        .map(
          (data) => data
              .map((json) => Booking.fromJson(json))
              .where(
                (b) =>
                    (b.status == BookingStatus.pending ||
                        b.status == BookingStatus.checkedIn ||
                        b.status == BookingStatus.inProgress) &&
                    b.bookingDate.toIso8601String().split('T')[0] == todayStr,
              )
              .toList(),
        );
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

  /// Auto-check overdue pending bookings — mark as no_show if 15 mins past start time
  Future<void> checkOverdueBookings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Get all pending bookings for today
    final pendingBookings = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('booking_date', todayStr)
        .eq('status', 'pending');

    for (final booking in pendingBookings) {
      final startTimeStr = booking['start_time'] as String;
      final parts = startTimeStr.split(':');
      final bookingStart = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // If 15 minutes past start time and still pending → no_show
      if (now.isAfter(bookingStart.add(const Duration(minutes: 15)))) {
        final bookingId = booking['id'] as String;
        final machineId = booking['machine_id'] as String;

        await _supabase
            .from('bookings')
            .update({'status': 'no_show'})
            .eq('id', bookingId);

        // Check if machine should be freed
        final otherActive = await _supabase
            .from('bookings')
            .select()
            .eq('machine_id', machineId)
            .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress');

        if (otherActive.isEmpty) {
          try {
            await _supabase
                .from('machines')
                .update({'status': 'available'})
                .eq('id', machineId)
                .select();
          } catch (e) {
            debugPrint('Failed to update machine status: $e');
          }
        }

        // Cancel scheduled notifications
        await NotificationService().cancelNotification(bookingId.hashCode);
        await NotificationService().cancelNotification(bookingId.hashCode + 2);

        // Notify user
        await NotificationService().showNotification(
          id: bookingId.hashCode + 7,
          title: 'การจองหมดเวลา',
          body: 'คุณไม่ได้มาใช้งานภายในเวลาที่กำหนด การจองถูกยกเลิกอัตโนมัติ',
        );
      }
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    // 1. Get the booking to find machineId
    final bookingData = await _supabase
        .from('bookings')
        .select('machine_id')
        .eq('id', bookingId)
        .single();

    final machineId = bookingData['machine_id'] as String;

    // 2. Cancel the booking
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);

    // 3. Check if there are other active bookings for this machine
    final otherBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress');

    // 4. If no other active bookings, set machine back to available
    if (otherBookings.isEmpty) {
      try {
        await _supabase
            .from('machines')
            .update({'status': 'available'})
            .eq('id', machineId)
            .select();
      } catch (e) {
        debugPrint('Failed to update machine status: $e');
      }
    }

    // 5. Cancel all scheduled notifications for this booking
    await NotificationService().cancelNotification(bookingId.hashCode);
    await NotificationService().cancelNotification(bookingId.hashCode + 2);

    // 6. Show instant notification — booking cancelled
    await NotificationService().showNotification(
      id: bookingId.hashCode + 3,
      title: 'ยกเลิกการจองแล้ว',
      body: 'การจองของคุณถูกยกเลิกเรียบร้อยแล้ว',
    );
  }

  /// Check if the given time slot conflicts with existing bookings for this machine.
  /// Returns the conflicting booking's time range string if conflict exists, or null if available.
  Future<String?> checkTimeConflict({
    required String machineId,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final startStr = _formatTime(startTime);
    final endStr = _formatTime(endTime);
    final dateStr = startTime.toIso8601String().split('T')[0];

    final existingBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .eq('booking_date', dateStr)
        .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress')
        .gte('end_time', startStr)
        .lte('start_time', endStr);

    if (existingBookings.isNotEmpty) {
      final conflict = existingBookings.first;
      final cStart = (conflict['start_time'] as String).substring(0, 5);
      final cEnd = (conflict['end_time'] as String).substring(0, 5);
      return '$cStart - $cEnd';
    }
    return null;
  }

  /// Check in — user confirms they are at the machine and starting to use it
  Future<void> checkInBooking(String bookingId) async {
    // 1. Update booking status to in_progress + set checked_in_at
    await _supabase
        .from('bookings')
        .update({
          'status': 'in_progress',
          'checked_in_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);

    // 2. Get machine id to update status
    final bookingData = await _supabase
        .from('bookings')
        .select('machine_id')
        .eq('id', bookingId)
        .single();

    final machineId = bookingData['machine_id'] as String;

    // 3. Update machine to in_use
    try {
      await _supabase
          .from('machines')
          .update({'status': 'in_use'})
          .eq('id', machineId)
          .select();
    } catch (e) {
      debugPrint('Failed to update machine status: $e');
    }

    // 4. Show notification
    await NotificationService().showNotification(
      id: bookingId.hashCode + 4,
      title: 'เริ่มใช้งานแล้ว!',
      body: 'เครื่องกำลังทำงาน เราจะแจ้งเตือนเมื่อเสร็จสิ้น',
    );

    // 5. Schedule notification when cycle should be complete
    // Get end time from booking
    final fullBooking = await _supabase
        .from('bookings')
        .select()
        .eq('id', bookingId)
        .single();

    final endTimeStr = fullBooking['end_time'] as String;
    final bookingDate = DateTime.parse(fullBooking['booking_date'] as String);
    final endParts = endTimeStr.split(':');
    final endDateTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    if (endDateTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: bookingId.hashCode + 5,
        title: 'ซักผ้าเสร็จแล้ว!',
        body: 'เครื่องทำงานเสร็จสิ้นแล้ว กรุณามารับผ้าของคุณ',
        scheduledDate: endDateTime,
      );
    }
  }

  /// Complete booking — mark as done and free the machine
  Future<void> completeBooking(String bookingId) async {
    // 1. Get machine id
    final bookingData = await _supabase
        .from('bookings')
        .select('machine_id')
        .eq('id', bookingId)
        .single();

    final machineId = bookingData['machine_id'] as String;

    // 2. Complete the booking
    await _supabase
        .from('bookings')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);

    // 3. Check other active bookings
    final otherBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress');

    // 4. Free machine if no other bookings
    if (otherBookings.isEmpty) {
      try {
        await _supabase
            .from('machines')
            .update({'status': 'available'})
            .eq('id', machineId)
            .select();
      } catch (e) {
        debugPrint('Failed to update machine status: $e');
      }
    }

    // 5. Cancel end-time notification and show completion
    await NotificationService().cancelNotification(bookingId.hashCode + 5);
    await NotificationService().showNotification(
      id: bookingId.hashCode + 6,
      title: 'เสร็จสิ้น!',
      body: 'การซักผ้าเสร็จสมบูรณ์แล้ว ขอบคุณที่ใช้บริการ',
    );
  }
}
