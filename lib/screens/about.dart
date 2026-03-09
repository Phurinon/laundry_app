import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เกี่ยวกับเรา',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightest,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: const Icon(
                  Icons.local_laundry_service_rounded,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Laundry App',
                style: GoogleFonts.prompt(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.prompt(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              _buildSectionCard(
                context,
                title: 'จุดประสงค์ของแอป',
                content:
                    'แอปนี้ช่วยให้คุณตรวจสอบสถานะเครื่องซักผ้าได้แบบเรียลไทม์ จองคิวล่วงหน้า และรับการแจ้งเตือนเมื่อซักเสร็จ เพื่อความสะดวกและประหยัดเวลาในการซักผ้าของคุณ',
                icon: Icons.info_outline_rounded,
              ),

              const SizedBox(height: 16),

              _buildSectionCard(
                context,
                title: 'ผู้พัฒนา',
                content:
                    'ส่วนหนึ่งของวิชา 261497 Mobile Application Development\nภาควิชาวิศวกรรมคอมพิวเตอร์ มหาวิทยาลัยเชียงใหม่ (CPE CMU)',
                icon: Icons.code_rounded,
              ),

              const SizedBox(height: 40),

              Text(
                '© 2025 Computer Engineering, CMU',
                style: GoogleFonts.prompt(
                  fontSize: 12,
                  color: AppTheme.neutral400,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.prompt(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.prompt(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
