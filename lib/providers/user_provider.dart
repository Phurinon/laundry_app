import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/app_user.dart';
import 'package:laundry_app/providers/auth_provider.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, AppUser?>(
      UserProfileNotifier.new,
    );

class UserProfileNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final session = ref.watch(authProvider).value;
    if (session == null) return null;

    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', session.user.id)
        .single();

    return AppUser.fromJson(response);
  }

  Future<void> updateDormitory(String dormitoryId) async {
    final session = ref.read(authProvider).value;
    if (session == null) return;

    state = const AsyncValue.loading();
    try {
      final response = await Supabase.instance.client
          .from('users')
          .update({'dormitory_id': dormitoryId})
          .eq('id', session.user.id)
          .select()
          .single();

      state = AsyncValue.data(AppUser.fromJson(response));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
