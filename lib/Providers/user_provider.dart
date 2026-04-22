import 'package:andaz/Models/user_like.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final UserLiked = FutureProvider<List<UserLike>>((ref) async{
   final response = await Supabase.instance.client.from('user_likes').select();
    return response.map((userliked) => UserLike.fromJson(userliked)).toList();
});
