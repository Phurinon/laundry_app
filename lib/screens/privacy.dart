import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'นโยบายความเป็นส่วนตัว',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'การเก็บรวบรวมข้อมูล',
                'เราเก็บรวบรวมข้อมูลที่คุณให้ไว้เมื่อคุณลงทะเบียนเข้าใช้งานแอปพลิเคชัน เช่น ชื่อ อีเมล และเบอร์โทรศัพท์ เพื่อใช้ในการยืนยันตัวตนและการแจ้งเตือนที่เป็นประโยชน์ต่อคุณ',
              ),
              const SizedBox(height: 24),
              _buildSection(
                'การใช้งานข้อมูล',
                'ข้อมูลของคุณจะถูกนำไปใช้เพื่อ:\n• จัดการการจองคิวเครื่องซักผ้า\n• ส่งการแจ้งเตือนเมื่อซักผ้าเสร็จหรือใกล้ถึงเวลาจอง\n• พัฒนาและปรับปรุงการให้บริการให้ดียิ่งขึ้น',
              ),
              const SizedBox(height: 24),
              _buildSection(
                'การรักษาความปลอดภัย',
                'เราให้ความสำคัญกับการรักษาความลับของข้อมูลส่วนบุคคลของคุณ และมีการใช้มาตรการรักษาความปลอดภัยที่ได้มาตรฐานเพื่อป้องกันการเข้าถึงข้อมูลโดยไม่ได้รับอนุญาต',
              ),
              const SizedBox(height: 24),
              _buildSection(
                'สิทธิ์ของคุณ',
                'คุณสามารถตรวจสอบ แก้ไข หรือขอลบข้อมูลส่วนบุคคลของคุณได้ทุกเมื่อผ่านหน้าโปรไฟล์ในแอปพลิเคชัน หรือติดต่อสอบถามเจ้าหน้าที่ผ่านช่องทางที่กำหนด',
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'ปรับปรุงล่าสุดเมื่อ: 10 มีนาคม 2026',
                  style: GoogleFonts.prompt(
                    fontSize: 12,
                    color: AppTheme.neutral400,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.prompt(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.prompt(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
