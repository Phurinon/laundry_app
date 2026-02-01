import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';

class MachineInfoScreen extends StatefulWidget {
  const MachineInfoScreen({super.key});

  @override
  State<MachineInfoScreen> createState() => _MachineInfoScreenState();
}

class _MachineInfoScreenState extends State<MachineInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลเครื่องซักผ้า',
          style: GoogleFonts.prompt(
            color: AppTheme.textPrimary,
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
                'เครื่องซักผ้า ...',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'ราคา : ...',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'เวลาที่เหลือ : 00:00 น.',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'น้ำหนักที่รองรับ : 10 กิโลกรัม',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'รุ่น : ...',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Image.asset('assets/images/washing_machine.png'),
            ],
          ),
        ),
      ),
    );
  }
}
