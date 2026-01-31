import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/screens/home.dart';
import 'package:laundry_app/screens/register.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'เข้าสู่ระบบ',
      //     style: GoogleFonts.prompt(
      //       fontSize: 20,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      body: Center(
        child: Container(
          color: AppTheme.background,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ยินดีต้อนรับสู่ Laundry App',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextField(
                decoration: InputDecoration(
                  // border: OutlineInputBorder(),
                  label: Text(
                    'ชื่อผู้ใช้',
                    style: GoogleFonts.prompt(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                  // border: OutlineInputBorder(),
                  label: Text(
                    'รหัสผ่าน',
                    style: GoogleFonts.prompt(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
                child: Text(
                  'เข้าสู่ระบบ',
                  style: GoogleFonts.prompt(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'หรือ',
                style: GoogleFonts.prompt(
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'เข้าสู่ระบบด้วย Google',
                      style: GoogleFonts.prompt(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Image.asset(
                      'assets/images/google_logo.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'สมัครสมาชิก',
                  style: GoogleFonts.prompt(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
