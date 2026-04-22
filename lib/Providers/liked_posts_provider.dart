import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final LikedPostsurlProvider = FutureProvider.family<List<String>, List<String>>(
  (ref, likedPostIds) async {
    final supabase = Supabase.instance.client;
    if (likedPostIds.isEmpty) {
      return [];
    }
    try {
      print("Fetching URLs for IDs: $likedPostIds");
      final response = await supabase
          .from('posts')
          .select('media_thumb_url')
          .inFilter('id', likedPostIds);
      print("Raw response: $response");
      final urls = (response as List)
          .map<String>((post) => post['media_thumb_url'] as String)
          .toList();

      print("URLs: $urls");
      print(urls);

      return urls;
    } catch (e) {
      print("SUPABASE ERROR: $e");

      rethrow;
    }
  },
);
