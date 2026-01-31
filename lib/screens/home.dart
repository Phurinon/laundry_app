import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/screens/setting.dart';
import 'package:laundry_app/models/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายการเครื่องซักผ้า',
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
          itemCount: machines.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machines[index].name,
                        style: GoogleFonts.prompt(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ราคา ${machines[index].price.toString()} บาท',
                        style: GoogleFonts.prompt(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    machines[index].isAvailable.toString() == 'true'
                        ? 'ว่าง'
                        : 'ไม่ว่าง',
                    style: GoogleFonts.prompt(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: machines[index].isAvailable == true
                          ? const Color.fromARGB(255, 65, 160, 68)
                          : Colors.red,
                    ),
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
