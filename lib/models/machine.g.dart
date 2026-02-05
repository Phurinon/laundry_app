// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MachineImpl _$$MachineImplFromJson(Map<String, dynamic> json) =>
    _$MachineImpl(
      id: json['id'] as String,
      dormitoryId: json['dormitory_id'] as String,
      machineNumber: json['machine_number'] as String,
      machineType: $enumDecode(_$MachineTypeEnumMap, json['machine_type']),
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$MachineStatusEnumMap, json['status']) ??
          MachineStatus.available,
      floor: (json['floor'] as num?)?.toInt(),
      locationDetail: json['location_detail'] as String?,
      qrCode: json['qr_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$MachineImplToJson(_$MachineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dormitory_id': instance.dormitoryId,
      'machine_number': instance.machineNumber,
      'machine_type': _$MachineTypeEnumMap[instance.machineType]!,
      'capacity': instance.capacity,
      'status': _$MachineStatusEnumMap[instance.status]!,
      'floor': instance.floor,
      'location_detail': instance.locationDetail,
      'qr_code': instance.qrCode,
      'is_active': instance.isActive,
    };

const _$MachineTypeEnumMap = {
  MachineType.washer: 'washer',
  MachineType.dryer: 'dryer',
};

const _$MachineStatusEnumMap = {
  MachineStatus.available: 'available',
  MachineStatus.inUse: 'in_use',
  MachineStatus.reserved: 'reserved',
  MachineStatus.maintenance: 'maintenance',
  MachineStatus.overdue: 'overdue',
};
