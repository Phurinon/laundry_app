import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/dormitory.dart';

final dormitoryProvider = FutureProvider.family<Dormitory?, String>((
  ref,
  dormId,
) async {
  final response = await Supabase.instance.client
      .from('dormitories')
      .select()
      .eq('id', dormId)
      .single();

  return Dormitory.fromJson(response);
});

final allDormitoriesProvider = FutureProvider<List<Dormitory>>((ref) async {
  final response = await Supabase.instance.client
      .from('dormitories')
      .select()
      .order('name');

  return response.map((json) => Dormitory.fromJson(json)).toList();
});
