import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laundry_app/models/machine.dart';

final machineProvider = StreamProvider<List<Machine>>((ref) {
  return Supabase.instance.client
      .from('machines')
      .stream(primaryKey: ['id'])
      .order('id', ascending: true)
      .map((data) => data.map((json) => Machine.fromJson(json)).toList());
});
