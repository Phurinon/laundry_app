import 'package:freezed_annotation/freezed_annotation.dart';

part 'dormitory.freezed.dart';
part 'dormitory.g.dart';

@freezed
class Dormitory with _$Dormitory {
  const factory Dormitory({
    required String id,
    required String name,
    String? location,
    @JsonKey(name: 'total_machines') @Default(0) int totalMachines,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Dormitory;

  factory Dormitory.fromJson(Map<String, dynamic> json) =>
      _$DormitoryFromJson(json);
}
