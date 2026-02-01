import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'บัญชีของฉัน',
          style: GoogleFonts.prompt(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 100,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'ชื่อผู้ใช้: Admin',
              style: GoogleFonts.prompt(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'admin@example.com',
              style: GoogleFonts.prompt(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
