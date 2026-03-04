import 'package:freezed_annotation/freezed_annotation.dart';

part 'machine_report.freezed.dart';
part 'machine_report.g.dart';

enum ReportType {
  @JsonValue('forgot_laundry')
  forgotLaundry,
  @JsonValue('machine_broken')
  machineBroken,
  @JsonValue('used_without_booking')
  usedWithoutBooking,
  @JsonValue('other')
  other,
}

enum ReportStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('resolved')
  resolved,
  @JsonValue('dismissed')
  dismissed,
}

@freezed
class MachineReport with _$MachineReport {
  const factory MachineReport({
    required String id,
    @JsonKey(name: 'reporter_id') required String reporterId,
    @JsonKey(name: 'machine_id') required String machineId,
    @JsonKey(name: 'booking_id') String? bookingId,
    @JsonKey(name: 'report_type') required ReportType reportType,
    String? description,
    @Default(ReportStatus.pending) ReportStatus status,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MachineReport;

  factory MachineReport.fromJson(Map<String, dynamic> json) =>
      _$MachineReportFromJson(json);
}
