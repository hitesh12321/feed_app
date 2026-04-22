import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userLikedProvider = FutureProvider.family<List<String>, String>((
  ref,
  String userId,
) async {
  final response = await Supabase.instance.client
      .from('user_likes')
      .select('post_id')
      .eq('user_id', userId); // ✅ filter yahan
  // sirf post_id ki list chahiye
  return response.map((row) => row['post_id'] as String).toList();
});

Future<void> addLike(String userId, String postId) async {
  try {
    final response = await Supabase.instance.client.from('user_likes').insert({
      'user_id': userId,
      'post_id': postId,
    });

    if (response.error != null) {
      throw Exception('Failed to add like: ${response.error!.message}');
    }
  } catch (e) {
    throw Exception('Failed to add like: $e');
  }
}
Future<void> removeLike(String userId, String postId) async {
  try {
    final response = await Supabase.instance.client
        .from('user_likes')
        .delete()
        .eq('user_id', userId)
        .eq('post_id', postId);

    if (response.error != null) {
      throw Exception('Failed to remove like: ${response.error!.message}');
    }
  } catch (e) {
    throw Exception('Failed to remove like: $e');
  }
}
