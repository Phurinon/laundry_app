import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/services/notification_service.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/providers/machine_provider.dart';

enum MachineWorkStatus { idle, fillingWater, washing, spinning, finished }

extension MachineWorkStatusExt on MachineWorkStatus {
  String get name {
    switch (this) {
      case MachineWorkStatus.idle:
        return 'รอการทำงาน';
      case MachineWorkStatus.fillingWater:
        return 'กำลังเติมน้ำ';
      case MachineWorkStatus.washing:
        return 'กำลังซัก';
      case MachineWorkStatus.spinning:
        return 'กำลังปั่นหมาด';
      case MachineWorkStatus.finished:
        return 'ซักเสร็จสิ้น';
    }
  }
}

class MachineSignalState {
  final double currentAmps;
  final MachineWorkStatus status;
  final String? machineId;

  MachineSignalState({
    this.currentAmps = 0.0,
    this.status = MachineWorkStatus.idle,
    this.machineId,
  });

  MachineSignalState copyWith({
    double? currentAmps,
    MachineWorkStatus? status,
    String? machineId,
  }) {
    return MachineSignalState(
      currentAmps: currentAmps ?? this.currentAmps,
      status: status ?? this.status,
      machineId: machineId ?? this.machineId,
    );
  }
}

class MachineSignalNotifier extends Notifier<MachineSignalState> {
  StreamSubscription<double>? _subscription;

  @override
  MachineSignalState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return MachineSignalState();
  }

  void startMockWashing({required String machineId, String? bookingId}) {
    _subscription?.cancel();

    state = MachineSignalState(
      currentAmps: 0.0,
      status: MachineWorkStatus.fillingWater,
      machineId: machineId,
    );

    _subscription = _getMachineCurrentStream().listen((amps) async {
      final newStatus = _determineStatus(amps);

      if (state.status != MachineWorkStatus.idle &&
          newStatus == MachineWorkStatus.idle) {
        state = state.copyWith(
          currentAmps: amps,
          status: MachineWorkStatus.finished,
        );
        _triggerNotification();

        if (bookingId != null) {
          try {
            await ref.read(bookingProvider).completeBooking(bookingId);
            ref.invalidate(myBookingsProvider);
            ref.invalidate(activeBookingsProvider);
            ref.invalidate(machineProvider);
          } catch (e) {}
        }

        _subscription?.cancel();
      } else {
        state = state.copyWith(currentAmps: amps, status: newStatus);
      }
    });
  }

  void resetWork() {
    _subscription?.cancel();
    state = MachineSignalState(
      currentAmps: 0.0,
      status: MachineWorkStatus.idle,
    );
  }

  Stream<double> _getMachineCurrentStream() async* {
    final mockAmpsCycle = [
      0.5,
      0.8,
      3.2,
      4.5,
      2.1,
      4.0,
      8.5,
      9.2,
      7.8,
      0.0,
      0.0,
    ];

    for (var amp in mockAmpsCycle) {
      await Future.delayed(const Duration(seconds: 2));
      final noise = (Random().nextDouble() * 0.2) - 0.1;
      yield (amp > 0) ? amp + noise : amp;
    }
  }

  MachineWorkStatus _determineStatus(double ampere) {
    if (ampere == 0.0) return MachineWorkStatus.idle;
    if (ampere > 0.0 && ampere <= 1.0) return MachineWorkStatus.fillingWater;
    if (ampere > 1.0 && ampere <= 5.0) return MachineWorkStatus.washing;
    if (ampere > 5.0) return MachineWorkStatus.spinning;
    return MachineWorkStatus.idle;
  }

  void _triggerNotification() {
    NotificationService().showNotification(
      id: 999,
      title: 'ผ้าของคุณซักเสร็จแล้ว!',
      body: 'รบกวนนำผ้าออกจากเครื่องและปิดฝาด้วยครับ',
    );
  }
}

final machineSignalProvider =
    NotifierProvider<MachineSignalNotifier, MachineSignalState>(() {
      return MachineSignalNotifier();
    });
