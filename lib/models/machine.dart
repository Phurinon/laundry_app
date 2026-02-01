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
  final double weight;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.isAvailable,
    required this.weight,
  });
}

List<Machine> machines = [
  Machine(
    id: 1,
    name: 'เครื่องซักผ้า 1',
    type: MachineType.washer,
    price: 20,
    isAvailable: true,
    weight: 10,
  ),
  Machine(
    id: 2,
    name: 'เครื่องอบผ้า 1',
    type: MachineType.dryer,
    price: 20,
    isAvailable: true,
    weight: 10,
  ),
  Machine(
    id: 3,
    name: 'เครื่องซักผ้า 2',
    type: MachineType.washer,
    price: 50,
    isAvailable: false,
    weight: 20,
  ),
  Machine(
    id: 4,
    name: 'เครื่องอบผ้า 2',
    type: MachineType.dryer,
    price: 50,
    isAvailable: true,
    weight: 20,
  ),
];
