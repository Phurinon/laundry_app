// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MachineReportImpl _$$MachineReportImplFromJson(Map<String, dynamic> json) =>
    _$MachineReportImpl(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      machineId: json['machine_id'] as String,
      bookingId: json['booking_id'] as String?,
      reportType: $enumDecode(_$ReportTypeEnumMap, json['report_type']),
      description: json['description'] as String?,
      status:
          $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
          ReportStatus.pending,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MachineReportImplToJson(_$MachineReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter_id': instance.reporterId,
      'machine_id': instance.machineId,
      'booking_id': instance.bookingId,
      'report_type': _$ReportTypeEnumMap[instance.reportType]!,
      'description': instance.description,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$ReportTypeEnumMap = {
  ReportType.forgotLaundry: 'forgot_laundry',
  ReportType.machineBroken: 'machine_broken',
  ReportType.usedWithoutBooking: 'used_without_booking',
  ReportType.other: 'other',
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'pending',
  ReportStatus.resolved: 'resolved',
  ReportStatus.dismissed: 'dismissed',
};
