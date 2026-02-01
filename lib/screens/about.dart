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
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'แอปนี้เป็นแอปสำหรับบริการเช็คสถานะของเครื่องซักผ้า โดยเป็นส่วนหนึ่งของวิชา 261497 Mobile Application Development @Computer Engineering Chiang Mai University',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
