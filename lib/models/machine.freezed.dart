// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'machine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Machine _$MachineFromJson(Map<String, dynamic> json) {
  return _Machine.fromJson(json);
}

/// @nodoc
mixin _$Machine {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'dormitory_id')
  String get dormitoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'machine_number')
  String get machineNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'machine_type')
  MachineType get machineType => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  MachineStatus get status => throw _privateConstructorUsedError;
  int? get floor => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_detail')
  String? get locationDetail => throw _privateConstructorUsedError;
  @JsonKey(name: 'qr_code')
  String? get qrCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Machine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Machine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MachineCopyWith<Machine> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MachineCopyWith<$Res> {
  factory $MachineCopyWith(Machine value, $Res Function(Machine) then) =
      _$MachineCopyWithImpl<$Res, Machine>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'dormitory_id') String dormitoryId,
    @JsonKey(name: 'machine_number') String machineNumber,
    @JsonKey(name: 'machine_type') MachineType machineType,
    int capacity,
    MachineStatus status,
    int? floor,
    @JsonKey(name: 'location_detail') String? locationDetail,
    @JsonKey(name: 'qr_code') String? qrCode,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class _$MachineCopyWithImpl<$Res, $Val extends Machine>
    implements $MachineCopyWith<$Res> {
  _$MachineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Machine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dormitoryId = null,
    Object? machineNumber = null,
    Object? machineType = null,
    Object? capacity = null,
    Object? status = null,
    Object? floor = freezed,
    Object? locationDetail = freezed,
    Object? qrCode = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dormitoryId: null == dormitoryId
                ? _value.dormitoryId
                : dormitoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            machineNumber: null == machineNumber
                ? _value.machineNumber
                : machineNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            machineType: null == machineType
                ? _value.machineType
                : machineType // ignore: cast_nullable_to_non_nullable
                      as MachineType,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MachineStatus,
            floor: freezed == floor
                ? _value.floor
                : floor // ignore: cast_nullable_to_non_nullable
                      as int?,
            locationDetail: freezed == locationDetail
                ? _value.locationDetail
                : locationDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            qrCode: freezed == qrCode
                ? _value.qrCode
                : qrCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MachineImplCopyWith<$Res> implements $MachineCopyWith<$Res> {
  factory _$$MachineImplCopyWith(
    _$MachineImpl value,
    $Res Function(_$MachineImpl) then,
  ) = __$$MachineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'dormitory_id') String dormitoryId,
    @JsonKey(name: 'machine_number') String machineNumber,
    @JsonKey(name: 'machine_type') MachineType machineType,
    int capacity,
    MachineStatus status,
    int? floor,
    @JsonKey(name: 'location_detail') String? locationDetail,
    @JsonKey(name: 'qr_code') String? qrCode,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class __$$MachineImplCopyWithImpl<$Res>
    extends _$MachineCopyWithImpl<$Res, _$MachineImpl>
    implements _$$MachineImplCopyWith<$Res> {
  __$$MachineImplCopyWithImpl(
    _$MachineImpl _value,
    $Res Function(_$MachineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Machine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dormitoryId = null,
    Object? machineNumber = null,
    Object? machineType = null,
    Object? capacity = null,
    Object? status = null,
    Object? floor = freezed,
    Object? locationDetail = freezed,
    Object? qrCode = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _$MachineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dormitoryId: null == dormitoryId
            ? _value.dormitoryId
            : dormitoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        machineNumber: null == machineNumber
            ? _value.machineNumber
            : machineNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        machineType: null == machineType
            ? _value.machineType
            : machineType // ignore: cast_nullable_to_non_nullable
                  as MachineType,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MachineStatus,
        floor: freezed == floor
            ? _value.floor
            : floor // ignore: cast_nullable_to_non_nullable
                  as int?,
        locationDetail: freezed == locationDetail
            ? _value.locationDetail
            : locationDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        qrCode: freezed == qrCode
            ? _value.qrCode
            : qrCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MachineImpl implements _Machine {
  const _$MachineImpl({
    required this.id,
    @JsonKey(name: 'dormitory_id') required this.dormitoryId,
    @JsonKey(name: 'machine_number') required this.machineNumber,
    @JsonKey(name: 'machine_type') required this.machineType,
    this.capacity = 0,
    this.status = MachineStatus.available,
    this.floor,
    @JsonKey(name: 'location_detail') this.locationDetail,
    @JsonKey(name: 'qr_code') this.qrCode,
    @JsonKey(name: 'is_active') this.isActive = true,
  });

  factory _$MachineImpl.fromJson(Map<String, dynamic> json) =>
      _$$MachineImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'dormitory_id')
  final String dormitoryId;
  @override
  @JsonKey(name: 'machine_number')
  final String machineNumber;
  @override
  @JsonKey(name: 'machine_type')
  final MachineType machineType;
  @override
  @JsonKey()
  final int capacity;
  @override
  @JsonKey()
  final MachineStatus status;
  @override
  final int? floor;
  @override
  @JsonKey(name: 'location_detail')
  final String? locationDetail;
  @override
  @JsonKey(name: 'qr_code')
  final String? qrCode;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'Machine(id: $id, dormitoryId: $dormitoryId, machineNumber: $machineNumber, machineType: $machineType, capacity: $capacity, status: $status, floor: $floor, locationDetail: $locationDetail, qrCode: $qrCode, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MachineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dormitoryId, dormitoryId) ||
                other.dormitoryId == dormitoryId) &&
            (identical(other.machineNumber, machineNumber) ||
                other.machineNumber == machineNumber) &&
            (identical(other.machineType, machineType) ||
                other.machineType == machineType) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.locationDetail, locationDetail) ||
                other.locationDetail == locationDetail) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    dormitoryId,
    machineNumber,
    machineType,
    capacity,
    status,
    floor,
    locationDetail,
    qrCode,
    isActive,
  );

  /// Create a copy of Machine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MachineImplCopyWith<_$MachineImpl> get copyWith =>
      __$$MachineImplCopyWithImpl<_$MachineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MachineImplToJson(this);
  }
}

abstract class _Machine implements Machine {
  const factory _Machine({
    required final String id,
    @JsonKey(name: 'dormitory_id') required final String dormitoryId,
    @JsonKey(name: 'machine_number') required final String machineNumber,
    @JsonKey(name: 'machine_type') required final MachineType machineType,
    final int capacity,
    final MachineStatus status,
    final int? floor,
    @JsonKey(name: 'location_detail') final String? locationDetail,
    @JsonKey(name: 'qr_code') final String? qrCode,
    @JsonKey(name: 'is_active') final bool isActive,
  }) = _$MachineImpl;

  factory _Machine.fromJson(Map<String, dynamic> json) = _$MachineImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'dormitory_id')
  String get dormitoryId;
  @override
  @JsonKey(name: 'machine_number')
  String get machineNumber;
  @override
  @JsonKey(name: 'machine_type')
  MachineType get machineType;
  @override
  int get capacity;
  @override
  MachineStatus get status;
  @override
  int? get floor;
  @override
  @JsonKey(name: 'location_detail')
  String? get locationDetail;
  @override
  @JsonKey(name: 'qr_code')
  String? get qrCode;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of Machine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MachineImplCopyWith<_$MachineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
