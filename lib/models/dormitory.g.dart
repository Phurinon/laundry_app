// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dormitory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DormitoryImpl _$$DormitoryImplFromJson(Map<String, dynamic> json) =>
    _$DormitoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      totalMachines: (json['total_machines'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$DormitoryImplToJson(_$DormitoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'total_machines': instance.totalMachines,
      'created_at': instance.createdAt?.toIso8601String(),
    };
