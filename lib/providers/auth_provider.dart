import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = NotifierProvider<AuthProvider, AsyncValue<Session?>>(
  AuthProvider.new,
);

class AuthProvider extends Notifier<AsyncValue<Session?>> {
  final _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  AsyncValue<Session?> build() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      state = AsyncValue.data(data.session);
    });

    return AsyncValue.data(_supabase.auth.currentSession);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String phone,
  ) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );

      if (response.session == null) {
        state = AsyncValue.error(
          'กรุณายืนยันอีเมลที่ส่งไปที่กล่องข้อความของท่าน ก่อนเข้าใช้งาน',
          StackTrace.current,
        );
      }
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signOut();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser({
    String? fullName,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;

    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
