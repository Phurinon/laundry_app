import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/services/notification_service.dart';

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

  MachineSignalState({
    this.currentAmps = 0.0,
    this.status = MachineWorkStatus.idle,
  });

  MachineSignalState copyWith({
    double? currentAmps,
    MachineWorkStatus? status,
  }) {
    return MachineSignalState(
      currentAmps: currentAmps ?? this.currentAmps,
      status: status ?? this.status,
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

  void startMockWashing() {
    _subscription?.cancel();

    // Reset state before starting
    state = MachineSignalState(
      currentAmps: 0.0,
      status: MachineWorkStatus.fillingWater,
    );

    _subscription = _getMachineCurrentStream().listen((amps) {
      final newStatus = _determineStatus(amps);

      // Check if finished (status changes to idle and it was doing something)
      if (state.status != MachineWorkStatus.idle &&
          newStatus == MachineWorkStatus.idle) {
        state = state.copyWith(
          currentAmps: amps,
          status: MachineWorkStatus.finished,
        );
        _triggerNotification();
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
      0.5, 0.8, // เติมน้ำ
      3.2, 4.5, 2.1, 4.0, // ซัก
      8.5, 9.2, 7.8, // ปั่นหมาด
      0.0, 0.0, // เสร็จสิ้น (Idle)
    ];

    for (var amp in mockAmpsCycle) {
      await Future.delayed(
        const Duration(seconds: 2),
      ); // สมมติ 1 สเตป = 2 วิ เพื่อให้เห็นภาพช้าขึ้น
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
      title: 'ซักผ้าเสร็จแล้ว! 🧺',
      body: 'รบกวนนำผ้าออกจากเครื่องและปิดฝาด้วยครับ',
    );
  }
}

final machineSignalProvider =
    NotifierProvider<MachineSignalNotifier, MachineSignalState>(() {
      return MachineSignalNotifier();
    });
