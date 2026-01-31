import 'package:flutter/material.dart';
import 'package:laundry_app/screens/register.dart';
import 'package:laundry_app/models/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laundry App',
      theme: AppTheme.lightTheme,
      home: RegisterScreen(),
    );
  }
}
