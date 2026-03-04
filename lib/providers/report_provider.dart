import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/machine_report.dart';
import 'package:uuid/uuid.dart';

final reportProvider = Provider((ref) => ReportService());

/// Stream of current user's reports
final myReportsProvider = StreamProvider<List<MachineReport>>((ref) {
  return ref.watch(reportProvider).getMyReports();
});

class ReportService {
  final _supabase = Supabase.instance.client;

  /// Submit a new machine problem report
  Future<void> submitReport({
    required String machineId,
    required ReportType reportType,
    String? bookingId,
    String? description,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('กรุณาเข้าสู่ระบบก่อนรายงาน');
    }

    final id = const Uuid().v4();
    final now = DateTime.now();

    await _supabase.from('reports').insert({
      'id': id,
      'reporter_id': userId,
      'machine_id': machineId,
      if (bookingId != null) 'booking_id': bookingId,
      'report_type': reportType == ReportType.forgotLaundry
          ? 'forgot_laundry'
          : reportType == ReportType.machineBroken
          ? 'machine_broken'
          : reportType == ReportType.usedWithoutBooking
          ? 'used_without_booking'
          : 'other',
      'description': description,
      'status': 'pending',
      'created_at': now.toIso8601String(),
    });
  }

  /// Get all reports submitted by the current user
  Stream<List<MachineReport>> getMyReports() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('reports')
        .stream(primaryKey: ['id'])
        .eq('reporter_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => MachineReport.fromJson(e)).toList());
  }

  /// Get reports for a specific machine
  Future<List<MachineReport>> getReportsForMachine(String machineId) async {
    final data = await _supabase
        .from('reports')
        .select()
        .eq('machine_id', machineId)
        .order('created_at', ascending: false);

    return data.map((e) => MachineReport.fromJson(e)).toList();
  }
}
