import 'package:andaz/Providers/liked_posts_provider.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final userLikedPosts = ref.watch(userLikedProvider(kUserId));
    // final likedPostIds = userLikedPosts.asData?.value ?? [];

    // yha mere pass userLikedProvider se liked post ids aa rhi hai, ab mujhe un post ids ke details fetch krne hai, uske liye mujhe ek aur provider create krna padega jo post details fetch karega, fir main us provider ko use krke liked post details ko display krunga.
    return Scaffold(
      appBar: AppBar(title: Text("liked")),
      body: userLikedPosts.when(
        data: (postids) {
          final likeimageurls = ref.watch(LikedPostsurlProvider(postids));

          return likeimageurls.when(
            loading: () => Center(child: CircularProgressIndicator()),

            error: (error, stack) => Center(child: Text('Error: $error')),

            data: (urls) => ListView.builder(
              controller: _scrollController,
              itemCount: urls.length,
              itemBuilder: (context, index) {
                final postUrl = urls[index];

                return ListTile(
                  leading: Image.network(postUrl, width: 50, height: 60),

                  title: Text('Liked Post ${index + 1}'),
                );
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
