// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dormitory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Dormitory _$DormitoryFromJson(Map<String, dynamic> json) {
  return _Dormitory.fromJson(json);
}

/// @nodoc
mixin _$Dormitory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_machines')
  int get totalMachines => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Dormitory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dormitory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DormitoryCopyWith<Dormitory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DormitoryCopyWith<$Res> {
  factory $DormitoryCopyWith(Dormitory value, $Res Function(Dormitory) then) =
      _$DormitoryCopyWithImpl<$Res, Dormitory>;
  @useResult
  $Res call({
    String id,
    String name,
    String? location,
    @JsonKey(name: 'total_machines') int totalMachines,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$DormitoryCopyWithImpl<$Res, $Val extends Dormitory>
    implements $DormitoryCopyWith<$Res> {
  _$DormitoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dormitory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? totalMachines = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalMachines: null == totalMachines
                ? _value.totalMachines
                : totalMachines // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DormitoryImplCopyWith<$Res>
    implements $DormitoryCopyWith<$Res> {
  factory _$$DormitoryImplCopyWith(
    _$DormitoryImpl value,
    $Res Function(_$DormitoryImpl) then,
  ) = __$$DormitoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? location,
    @JsonKey(name: 'total_machines') int totalMachines,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$DormitoryImplCopyWithImpl<$Res>
    extends _$DormitoryCopyWithImpl<$Res, _$DormitoryImpl>
    implements _$$DormitoryImplCopyWith<$Res> {
  __$$DormitoryImplCopyWithImpl(
    _$DormitoryImpl _value,
    $Res Function(_$DormitoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Dormitory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? totalMachines = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DormitoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalMachines: null == totalMachines
            ? _value.totalMachines
            : totalMachines // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DormitoryImpl implements _Dormitory {
  const _$DormitoryImpl({
    required this.id,
    required this.name,
    this.location,
    @JsonKey(name: 'total_machines') this.totalMachines = 0,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$DormitoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DormitoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? location;
  @override
  @JsonKey(name: 'total_machines')
  final int totalMachines;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Dormitory(id: $id, name: $name, location: $location, totalMachines: $totalMachines, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DormitoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.totalMachines, totalMachines) ||
                other.totalMachines == totalMachines) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, location, totalMachines, createdAt);

  /// Create a copy of Dormitory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DormitoryImplCopyWith<_$DormitoryImpl> get copyWith =>
      __$$DormitoryImplCopyWithImpl<_$DormitoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DormitoryImplToJson(this);
  }
}

abstract class _Dormitory implements Dormitory {
  const factory _Dormitory({
    required final String id,
    required final String name,
    final String? location,
    @JsonKey(name: 'total_machines') final int totalMachines,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$DormitoryImpl;

  factory _Dormitory.fromJson(Map<String, dynamic> json) =
      _$DormitoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get location;
  @override
  @JsonKey(name: 'total_machines')
  int get totalMachines;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of Dormitory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DormitoryImplCopyWith<_$DormitoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
