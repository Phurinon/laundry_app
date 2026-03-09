import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

class _UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const _UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    final dt = DateTime.parse(json);
    // If the string doesn't end in 'Z' or have an offset, it's parsed as local.
    // We want to treat it as UTC if it's not already.
    return dt.isUtc
        ? dt
        : DateTime.utc(
            dt.year,
            dt.month,
            dt.day,
            dt.hour,
            dt.minute,
            dt.second,
            dt.millisecond,
            dt.microsecond,
          );
  }

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

class _NullableUtcDateTimeConverter
    implements JsonConverter<DateTime?, String?> {
  const _NullableUtcDateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    return const _UtcDateTimeConverter().fromJson(json);
  }

  @override
  String? toJson(DateTime? object) => object?.toUtc().toIso8601String();
}

enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('checked_in')
  checkedIn,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'machine_id') required String machineId,
    @_UtcDateTimeConverter()
    @JsonKey(name: 'start_time')
    required DateTime startTime,
    @_UtcDateTimeConverter()
    @JsonKey(name: 'end_time')
    required DateTime endTime,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'cycle_type') String? cycleType,
    @Default(BookingStatus.pending) BookingStatus status,
    @_NullableUtcDateTimeConverter()
    @JsonKey(name: 'checked_in_at')
    DateTime? checkedInAt,
    @_NullableUtcDateTimeConverter()
    @JsonKey(name: 'completed_at')
    DateTime? completedAt,
    String? notes,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
