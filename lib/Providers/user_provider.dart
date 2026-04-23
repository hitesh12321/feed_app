import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userLikedProvider = FutureProvider.family<List<String>, String>((
  ref,
  String userId,
) async {
  final response = await Supabase.instance.client
      .from('user_likes')
      .select('post_id')
      .eq('user_id', userId); 

  return response.map((row) => row['post_id'] as String).toList();
});



