import 'package:flutter/material.dart';

class SettingList {
  final String title;
  final IconData icon;

  SettingList({required this.title, required this.icon});
}

final List<SettingList> settingList = [
  SettingList(title: 'บัญชีของฉัน', icon: Icons.person),
  SettingList(title: 'การแจ้งเตือน', icon: Icons.notification_important),
  SettingList(title: 'ความเป็นส่วนตัว', icon: Icons.lock),
  SettingList(title: 'เกี่ยวกับ', icon: Icons.info),
];
