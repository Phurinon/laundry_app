import 'package:flutter/material.dart';

enum MachineType {
  washer,
  dryer,
}

class Machine {
  final int id;
  final String name;
  final MachineType type;
  final double price;
  final bool isAvailable;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.isAvailable,
  });
}

List<Machine> machines = [
  Machine(
    id: 1,
    name: 'เครื่องซักผ้า 1',
    type: MachineType.washer,
    price: 20,
    isAvailable: true,
  ),
  Machine(
    id: 2,
    name: 'เครื่องอบผ้า 1',
    type: MachineType.dryer,
    price: 20,
    isAvailable: true,
  ),
  Machine(
    id: 3,
    name: 'เครื่องซักผ้า 2',
    type: MachineType.washer,
    price: 20,
    isAvailable: false,
  ),
  Machine(
    id: 4,
    name: 'เครื่องอบผ้า 2',
    type: MachineType.dryer,
    price: 20,
    isAvailable: true,
  ),
];
