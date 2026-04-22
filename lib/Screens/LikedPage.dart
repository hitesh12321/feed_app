import 'package:andaz/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Likedpage extends ConsumerStatefulWidget {
  const Likedpage({super.key});

  @override
  ConsumerState<Likedpage> createState() => _LikedpageState();
}

class _LikedpageState extends ConsumerState<Likedpage> {
  final String kUserId = dotenv.env['USER_ID']!;

  @override
  Widget build(BuildContext context) {
    final userLikedPosts = ref.watch(userLikedProvider(kUserId));

    return Scaffold(
      appBar: AppBar(title: Text("liked")),
      body: userLikedPosts.when(
        data: (likedPostIds) => ListView.builder(
          itemCount: likedPostIds.length,
          itemBuilder: (context, index) {
            final postId = likedPostIds[index];
            return ListTile(title: Text('Liked Post ID: $postId'));
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
