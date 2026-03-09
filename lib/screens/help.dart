import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'ช่วยเหลือ',
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
              _buildSectionTitle('คำถามที่พบบ่อย (FAQ)'),
              const SizedBox(height: 16),
              _buildFAQItem(
                'วิธีการจองคิวซักผ้า?',
                'คุณสามารถจองคิวได้จากหน้าหลัก โดยเลือกเครื่องที่ว่างและเลือกเวลาที่ต้องการ จากนั้นกด "จองคิวเลย"',
              ),
              _buildFAQItem(
                'จะทราบได้อย่างไรว่าซักเสร็จแล้ว?',
                'แอปพลิเคชันจะส่งการแจ้งเตือนไปยังโทรศัพท์ของคุณเมื่อเครื่องทำงานเสร็จสิ้น และคุณยังสามารถดูสถานะแบบเรียลไทม์ได้ในหน้า "การจองของฉัน"',
              ),
              _buildFAQItem(
                'ยกเลิกการจองได้หรือไม่?',
                'คุณสามารถยกเลิกการจองได้ในหน้า "รายละเอียดการจอง" ก่อนที่เวลาจองจะเริ่มต้นขึ้น',
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('ติดต่อเรา'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildContactItem(
                      Icons.email_outlined,
                      'werasak_mayer@cmu.ac.th',
                      'ส่งอีเมลหาเรา',
                    ),
                    const Divider(height: 32),
                    _buildContactItem(
                      Icons.phone_outlined,
                      '081-234-5678',
                      'โทรสอบถามเจ้าหน้าที่',
                    ),
                    const Divider(height: 32),
                    _buildContactItem(
                      Icons.chat_bubble_outline_rounded,
                      '@laundry_app_line',
                      'ติดต่อผ่าน Line Official',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.prompt(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral100),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.prompt(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            answer,
            style: GoogleFonts.prompt(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryLightest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.prompt(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.prompt(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppTheme.neutral300,
        ),
      ],
    );
  }
}
