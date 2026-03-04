import 'package:flutter/material.dart';
import 'package:laundry_app/screens/register.dart';

/// LoginScreen ถูกรวมเข้ากับ RegisterScreen แล้ว
/// คลาสนี้เก็บไว้เพื่อ backward compatibility
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegisterScreen();
  }
}
