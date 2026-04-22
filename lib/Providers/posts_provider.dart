import 'package:andaz/Models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final feedProvider = FutureProvider<List<Post>>((ref) async {
  try {
    final response = await Supabase.instance.client.from('posts').select();
    return response.map((post) => Post.fromJson(post)).toList();
  } catch (e) {
    throw Exception('Failed to load posts: $e');
  }
});
