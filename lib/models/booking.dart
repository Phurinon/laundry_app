import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

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
    @JsonKey(name: 'booking_date') required DateTime bookingDate,
    @JsonKey(name: 'start_time') required String startTime, // Format: HH:MM:SS
    @JsonKey(name: 'end_time') required String endTime, // Format: HH:MM:SS
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'cycle_type') String? cycleType,
    @Default(BookingStatus.pending) BookingStatus status,
    @JsonKey(name: 'checked_in_at') DateTime? checkedInAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    String? notes,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
