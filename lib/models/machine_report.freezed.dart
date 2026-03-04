// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'machine_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MachineReport _$MachineReportFromJson(Map<String, dynamic> json) {
  return _MachineReport.fromJson(json);
}

/// @nodoc
mixin _$MachineReport {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'reporter_id')
  String get reporterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'machine_id')
  String get machineId => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_id')
  String? get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_type')
  ReportType get reportType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  ReportStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MachineReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MachineReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MachineReportCopyWith<MachineReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MachineReportCopyWith<$Res> {
  factory $MachineReportCopyWith(
    MachineReport value,
    $Res Function(MachineReport) then,
  ) = _$MachineReportCopyWithImpl<$Res, MachineReport>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'reporter_id') String reporterId,
    @JsonKey(name: 'machine_id') String machineId,
    @JsonKey(name: 'booking_id') String? bookingId,
    @JsonKey(name: 'report_type') ReportType reportType,
    String? description,
    ReportStatus status,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$MachineReportCopyWithImpl<$Res, $Val extends MachineReport>
    implements $MachineReportCopyWith<$Res> {
  _$MachineReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MachineReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterId = null,
    Object? machineId = null,
    Object? bookingId = freezed,
    Object? reportType = null,
    Object? description = freezed,
    Object? status = null,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reporterId: null == reporterId
                ? _value.reporterId
                : reporterId // ignore: cast_nullable_to_non_nullable
                      as String,
            machineId: null == machineId
                ? _value.machineId
                : machineId // ignore: cast_nullable_to_non_nullable
                      as String,
            bookingId: freezed == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            reportType: null == reportType
                ? _value.reportType
                : reportType // ignore: cast_nullable_to_non_nullable
                      as ReportType,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReportStatus,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MachineReportImplCopyWith<$Res>
    implements $MachineReportCopyWith<$Res> {
  factory _$$MachineReportImplCopyWith(
    _$MachineReportImpl value,
    $Res Function(_$MachineReportImpl) then,
  ) = __$$MachineReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'reporter_id') String reporterId,
    @JsonKey(name: 'machine_id') String machineId,
    @JsonKey(name: 'booking_id') String? bookingId,
    @JsonKey(name: 'report_type') ReportType reportType,
    String? description,
    ReportStatus status,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$MachineReportImplCopyWithImpl<$Res>
    extends _$MachineReportCopyWithImpl<$Res, _$MachineReportImpl>
    implements _$$MachineReportImplCopyWith<$Res> {
  __$$MachineReportImplCopyWithImpl(
    _$MachineReportImpl _value,
    $Res Function(_$MachineReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MachineReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterId = null,
    Object? machineId = null,
    Object? bookingId = freezed,
    Object? reportType = null,
    Object? description = freezed,
    Object? status = null,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MachineReportImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reporterId: null == reporterId
            ? _value.reporterId
            : reporterId // ignore: cast_nullable_to_non_nullable
                  as String,
        machineId: null == machineId
            ? _value.machineId
            : machineId // ignore: cast_nullable_to_non_nullable
                  as String,
        bookingId: freezed == bookingId
            ? _value.bookingId
            : bookingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        reportType: null == reportType
            ? _value.reportType
            : reportType // ignore: cast_nullable_to_non_nullable
                  as ReportType,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReportStatus,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MachineReportImpl implements _MachineReport {
  const _$MachineReportImpl({
    required this.id,
    @JsonKey(name: 'reporter_id') required this.reporterId,
    @JsonKey(name: 'machine_id') required this.machineId,
    @JsonKey(name: 'booking_id') this.bookingId,
    @JsonKey(name: 'report_type') required this.reportType,
    this.description,
    this.status = ReportStatus.pending,
    @JsonKey(name: 'resolved_at') this.resolvedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$MachineReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$MachineReportImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'reporter_id')
  final String reporterId;
  @override
  @JsonKey(name: 'machine_id')
  final String machineId;
  @override
  @JsonKey(name: 'booking_id')
  final String? bookingId;
  @override
  @JsonKey(name: 'report_type')
  final ReportType reportType;
  @override
  final String? description;
  @override
  @JsonKey()
  final ReportStatus status;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'MachineReport(id: $id, reporterId: $reporterId, machineId: $machineId, bookingId: $bookingId, reportType: $reportType, description: $description, status: $status, resolvedAt: $resolvedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MachineReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reporterId, reporterId) ||
                other.reporterId == reporterId) &&
            (identical(other.machineId, machineId) ||
                other.machineId == machineId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.reportType, reportType) ||
                other.reportType == reportType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reporterId,
    machineId,
    bookingId,
    reportType,
    description,
    status,
    resolvedAt,
    createdAt,
  );

  /// Create a copy of MachineReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MachineReportImplCopyWith<_$MachineReportImpl> get copyWith =>
      __$$MachineReportImplCopyWithImpl<_$MachineReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MachineReportImplToJson(this);
  }
}

abstract class _MachineReport implements MachineReport {
  const factory _MachineReport({
    required final String id,
    @JsonKey(name: 'reporter_id') required final String reporterId,
    @JsonKey(name: 'machine_id') required final String machineId,
    @JsonKey(name: 'booking_id') final String? bookingId,
    @JsonKey(name: 'report_type') required final ReportType reportType,
    final String? description,
    final ReportStatus status,
    @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$MachineReportImpl;

  factory _MachineReport.fromJson(Map<String, dynamic> json) =
      _$MachineReportImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'reporter_id')
  String get reporterId;
  @override
  @JsonKey(name: 'machine_id')
  String get machineId;
  @override
  @JsonKey(name: 'booking_id')
  String? get bookingId;
  @override
  @JsonKey(name: 'report_type')
  ReportType get reportType;
  @override
  String? get description;
  @override
  ReportStatus get status;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of MachineReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MachineReportImplCopyWith<_$MachineReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
