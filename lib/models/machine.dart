import 'package:freezed_annotation/freezed_annotation.dart';

part 'machine.freezed.dart';
part 'machine.g.dart';

enum MachineType {
  @JsonValue('washer')
  washer,
  @JsonValue('dryer')
  dryer,
}

enum MachineStatus {
  @JsonValue('available')
  available,
  @JsonValue('in_use')
  inUse,
  @JsonValue('reserved')
  reserved,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('overdue')
  overdue,
}

@freezed
class Machine with _$Machine {
  const factory Machine({
    required String id,
    @JsonKey(name: 'dormitory_id') required String dormitoryId,
    @JsonKey(name: 'machine_number') required String machineNumber,
    @JsonKey(name: 'machine_type') required MachineType machineType,
    @Default(0) int capacity,
    @Default(MachineStatus.available) MachineStatus status,
    int? floor,
    @JsonKey(name: 'location_detail') String? locationDetail,
    @JsonKey(name: 'qr_code') String? qrCode,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _Machine;

  factory Machine.fromJson(Map<String, dynamic> json) =>
      _$MachineFromJson(json);
}
