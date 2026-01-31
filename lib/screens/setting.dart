import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/settinglist.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/screens/login.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ตั้งค่า',
          style: GoogleFonts.prompt(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          itemCount: settingList.length + 1,
          itemBuilder: (context, index) {
            if (index == settingList.length) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'ออกจากระบบ',
                    style: GoogleFonts.prompt(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingList[index].title,
                        style: GoogleFonts.prompt(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    settingList[index].icon,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
