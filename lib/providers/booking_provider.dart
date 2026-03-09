import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final bookingProvider = Provider((ref) => BookingService());

final activeBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingProvider).getAllActiveBookings();
});

final myBookingsProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingProvider).getMyBookings();
});

final machineQueueProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      machineId,
    ) async {
      final activeBookings = await ref.watch(activeBookingsProvider.future);
      final supabase = Supabase.instance.client;

      final machineBookings = activeBookings
          .where((b) => b.machineId == machineId)
          .toList();

      if (machineBookings.isEmpty) {
        return [];
      }

      final userIds = machineBookings.map((b) => b.userId).toSet().toList();
      final usersResponse = await supabase
          .from('users')
          .select('id, full_name')
          .inFilter('id', userIds);

      final userMap = {
        for (final u in usersResponse)
          u['id'] as String: u['full_name'] as String,
      };

      return machineBookings.map((b) {
        return {
          'booking': b,
          'userName': userMap[b.userId] ?? 'ไม่ระบุชื่อ',
        };
      }).toList();
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

    final normalizedStart = DateTime.utc(
      startTime.toUtc().year,
      startTime.toUtc().month,
      startTime.toUtc().day,
      startTime.toUtc().hour,
      startTime.toUtc().minute,
    );
    final endTime = normalizedStart.add(Duration(minutes: durationMinutes));
    final startUtc = normalizedStart.toIso8601String();
    final endUtc = endTime.toIso8601String();

    final existingBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .inFilter('status', ['pending', 'checked_in', 'in_progress'])
        .lt('start_time', endUtc)
        .gt('end_time', startUtc);

    if (existingBookings.isNotEmpty) {
      throw Exception('ช่วงเวลานี้มีการจองแล้ว');
    }

    final booking = Booking(
      id: const Uuid().v4(),
      userId: userId,
      machineId: machineId,
      startTime: normalizedStart,
      endTime: endTime,
      durationMinutes: durationMinutes,
      status: BookingStatus.pending,
    );

    try {
      await _supabase.from('bookings').insert(booking.toJson());
    } on PostgrestException catch (e) {
      if (e.code == '23P01') {
        throw Exception('ช่วงเวลานี้มีการจองแล้ว (กรุณาเลือกเวลาอื่น)');
      }
      rethrow;
    }

    try {
      await _supabase
          .from('machines')
          .update({'status': 'reserved'})
          .eq('id', machineId)
          .select();
    } catch (e) {
      debugPrint('Failed to update machine status: $e');
    }

    final startStr = DateFormat('HH:mm').format(startTime);
    final endStr = DateFormat('HH:mm').format(endTime);

    await NotificationService().showNotification(
      id: booking.id.hashCode + 1,
      title: 'จองสำเร็จแล้ว!',
      body: 'เครื่อง $machineNumber เวลา $startStr - $endStr',
    );

    final reminder10 = startTime.subtract(const Duration(minutes: 10));
    if (reminder10.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: booking.id.hashCode,
        title: 'ใกล้ถึงเวลาซักผ้าแล้ว!',
        body: 'การจองของคุณที่เครื่อง $machineNumber จะเริ่มในอีก 10 นาที',
        scheduledDate: reminder10,
      );
    }

    if (startTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: booking.id.hashCode + 2,
        title: 'ถึงเวลาซักผ้าแล้ว!',
        body: 'เครื่อง $machineNumber พร้อมใช้งานแล้ว ไปซักผ้าได้เลย!',
        scheduledDate: startTime,
      );
    }
  }

  Stream<List<Booking>> getAllActiveBookings() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .gte('start_time', startOfToday.toUtc().toIso8601String())
        .map(
          (data) =>
              data
                  .map((json) => Booking.fromJson(json))
                  .where(
                    (b) =>
                        b.status == BookingStatus.pending ||
                        b.status == BookingStatus.checkedIn ||
                        b.status == BookingStatus.inProgress,
                  )
                  .toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime)),
        );
  }

  Stream<List<Booking>> getMyBookings() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('start_time', ascending: false)
        .map((data) => data.map((json) => Booking.fromJson(json)).toList());
  }

  Future<void> checkOverdueBookings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final nowUtc = DateTime.now().toUtc();

    final pendingOnes = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('status', 'pending');

    for (final bJson in pendingOnes) {
      final b = Booking.fromJson(bJson);
      if (nowUtc.isAfter(b.startTime.add(const Duration(minutes: 5)))) {
        await _supabase
            .from('bookings')
            .update({'status': 'no_show'})
            .eq('id', b.id);

        final otherActive = await _supabase
            .from('bookings')
            .select()
            .eq('machine_id', b.machineId)
            .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress');

        if (otherActive.isEmpty) {
          try {
            await _supabase
                .from('machines')
                .update({'status': 'available'})
                .eq('id', b.machineId)
                .select();
          } catch (e) {
            debugPrint('Failed to update machine status: $e');
          }
        }

        await NotificationService().cancelNotification(b.id.hashCode);
        await NotificationService().cancelNotification(b.id.hashCode + 2);

        await NotificationService().showNotification(
          id: b.id.hashCode + 7,
          title: 'การจองหมดเวลา',
          body:
              'คุณไม่ได้มาใช้งานภายในเวลาที่กำหนด (5 นาที) การจองถูกยกเลิกอัตโนมัติ',
        );
      }
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final bookingData = await _supabase
        .from('bookings')
        .select('machine_id')
        .eq('id', bookingId)
        .single();

    final machineId = bookingData['machine_id'] as String;

    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);

    final otherBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress');

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

    await NotificationService().cancelNotification(bookingId.hashCode);
    await NotificationService().cancelNotification(bookingId.hashCode + 2);

    await NotificationService().showNotification(
      id: bookingId.hashCode + 3,
      title: 'ยกเลิกการจองแล้ว',
      body: 'การจองของคุณถูกยกเลิกเรียบร้อยแล้ว',
    );
  }

  Future<String?> checkTimeConflict({
    required String machineId,
    required DateTime startTime,
    required int durationMinutes,
  }) async {
    final normalizedStart = DateTime.utc(
      startTime.toUtc().year,
      startTime.toUtc().month,
      startTime.toUtc().day,
      startTime.toUtc().hour,
      startTime.toUtc().minute,
    );
    final endTime = normalizedStart.add(Duration(minutes: durationMinutes));
    final startUtc = normalizedStart.toIso8601String();
    final endUtc = endTime.toIso8601String();

    final existingBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .inFilter('status', ['pending', 'checked_in', 'in_progress'])
        .lt('start_time', endUtc)
        .gt('end_time', startUtc);

    if (existingBookings.isNotEmpty) {
      final conflict = Booking.fromJson(existingBookings.first);
      final cStart = DateFormat('HH:mm').format(conflict.startTime.toLocal());
      final cEnd = DateFormat('HH:mm').format(conflict.endTime.toLocal());
      return '$cStart - $cEnd';
    }
    return null;
  }

  Future<void> checkInBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({
          'status': 'in_progress',
          'checked_in_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', bookingId);

    final bookingData = await _supabase
        .from('bookings')
        .select('machine_id, end_time')
        .eq('id', bookingId)
        .single();

    final machineId = bookingData['machine_id'] as String;
    final endDateTime = DateTime.parse(bookingData['end_time'] as String);

    try {
      await _supabase
          .from('machines')
          .update({'status': 'in_use'})
          .eq('id', machineId)
          .select();
    } catch (e) {
      debugPrint('Failed to update machine status: $e');
    }

    await NotificationService().showNotification(
      id: bookingId.hashCode + 4,
      title: 'เริ่มใช้งานแล้ว!',
      body: 'เครื่องกำลังทำงาน เราจะแจ้งเตือนเมื่อเสร็จสิ้น',
    );

    if (endDateTime.isAfter(DateTime.now().toUtc())) {
      await NotificationService().scheduleNotification(
        id: bookingId.hashCode + 5,
        title: 'ซักผ้าเสร็จแล้ว!',
        body: 'เครื่องทำงานเสร็จสิ้นแล้ว กรุณามารับผ้าของคุณ',
        scheduledDate: endDateTime.toLocal(),
      );
    }
  }

  Future<void> completeBooking(String bookingId) async {
    final bookingData = await _supabase
        .from('bookings')
        .select('machine_id')
        .eq('id', bookingId)
        .single();

    final machineId = bookingData['machine_id'] as String;

    await _supabase
        .from('bookings')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', bookingId);

    final otherBookings = await _supabase
        .from('bookings')
        .select()
        .eq('machine_id', machineId)
        .or('status.eq.pending,status.eq.checked_in,status.eq.in_progress');

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

    await NotificationService().cancelNotification(bookingId.hashCode + 5);

    await NotificationService().showNotification(
      id: bookingId.hashCode + 6,
      title: 'เสร็จสิ้น!',
      body: 'การซักผ้าเสร็จสมบูรณ์แล้ว ขอบคุณที่ใช้บริการ',
    );
  }
}
