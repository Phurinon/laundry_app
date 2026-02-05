// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      dormitoryId: json['dormitory_id'] as String?,
      roomNumber: json['room_number'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      penaltyPoints: (json['penalty_points'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'dormitory_id': instance.dormitoryId,
      'room_number': instance.roomNumber,
      'is_admin': instance.isAdmin,
      'penalty_points': instance.penaltyPoints,
    };
