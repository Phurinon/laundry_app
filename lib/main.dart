import 'package:flutter/material.dart';
import 'package:laundry_app/screens/register.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/config/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Notifications
  await NotificationService().init();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laundry App',
      theme: AppTheme.lightTheme,
      home: RegisterScreen(),
    );
  }
}
