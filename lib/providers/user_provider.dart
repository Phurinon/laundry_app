import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/app_user.dart';
import 'package:laundry_app/providers/auth_provider.dart';

final userProfileProvider = FutureProvider<AppUser?>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return null;

  final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('id', session.user.id)
      .single();

  return AppUser.fromJson(response);
});
